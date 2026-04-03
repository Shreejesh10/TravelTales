from fastapi import HTTPException, status
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import func
from typing import List, Optional

from app.model.models import Booking, Friend, Referral, TravelEvent
from app.schemas.schemas import (BookingCreate, EsewaInitResponse)
from app.services.notification_service import notify_friend_booking
from uuid import uuid4
import base64
import hashlib
import hmac
import os

ACTIVE_BOOKING_STATUSES = ("pending", "completed")


def _get_active_booked_people(db: Session, event_id: int) -> int:
    return (
        db.query(func.coalesce(func.sum(Booking.total_people), 0))
        .filter(
            Booking.event_id == event_id,
            Booking.status.in_(ACTIVE_BOOKING_STATUSES),
        )
        .scalar()
    )


def _sync_event_closed_status(db: Session, event: TravelEvent) -> None:
    active_booked_people = _get_active_booked_people(db, event.event_id)
    event.is_closed = active_booked_people >= event.max_people



def create_booking(db: Session, user_id: int, booking_data: BookingCreate) -> Booking:
    try:
        event = (
            db.query(TravelEvent)
            .filter(TravelEvent.event_id == booking_data.event_id)
            .with_for_update()
            .first()
        )

        if not event:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Event not found"
            )

        existing_booking = (
            db.query(Booking)
            .filter(
                Booking.user_id == user_id,
                Booking.event_id == booking_data.event_id,
                Booking.status.in_(ACTIVE_BOOKING_STATUSES),
            )
            .first()
        )
        if existing_booking:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Event already booked"
            )

        total_booked_people = _get_active_booked_people(db, booking_data.event_id)
        available_seats = event.max_people - total_booked_people

        if available_seats <= 0:
            event.is_closed = True
            db.commit()
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Event is full and closed"
            )

        if booking_data.total_people > available_seats:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Only {available_seats} seat(s) left"
            )

        for friend_user_id in booking_data.friend_user_ids:
            if friend_user_id == user_id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="You cannot invite yourself."
                )

            friend_low = min(user_id, friend_user_id)
            friend_high = max(user_id, friend_user_id)
            friendship = (
                db.query(Friend)
                .filter(
                    Friend.user_id == friend_low,
                    Friend.friend_user_id == friend_high,
                )
                .first()
            )
            if not friendship:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="One or more selected users are not in your friends list."
                )

        total_price = float(event.price or 0) * booking_data.total_people
        transaction_uuid = f"BOOK-{uuid4().hex[:12]}"

        new_booking = Booking(
            user_id=user_id,
            event_id=booking_data.event_id,
            total_people=booking_data.total_people,
            total_price=total_price,
            transaction_uuid=transaction_uuid,
            status="pending",
        )

        db.add(new_booking)
        db.flush()

        for friend_user_id in booking_data.friend_user_ids:
            db.add(
                Referral(
                    referred_by=user_id,
                    referred_to=friend_user_id,
                    booking_id=new_booking.booking_id,
                )
            )

        _sync_event_closed_status(db, event)

        db.commit()
        db.refresh(new_booking)

        return new_booking
    except HTTPException:
        db.rollback()
        raise
    except Exception:
        db.rollback()
        raise


def get_my_bookings(db: Session, user_id: int) -> List[Booking]:
    return (
        db.query(Booking)
        .options(
            joinedload(Booking.event).joinedload(TravelEvent.destination),
            joinedload(Booking.referrals).joinedload(Referral.referred_user),
        )
        .filter(Booking.user_id == user_id)
        .order_by(Booking.booked_at.desc())
        .all()
    )


def get_booking_by_id(db: Session, booking_id: int, user_id: int) -> Optional[Booking]:
    return (
        db.query(Booking)
        .options(
            joinedload(Booking.event).joinedload(TravelEvent.destination),
            joinedload(Booking.referrals).joinedload(Referral.referred_user),
        )
        .filter(
            Booking.booking_id == booking_id,
            Booking.user_id == user_id
        )
        .first()
    )


ESEWA_PRODUCT_CODE = os.environ.get("ESEWA_PRODUCT_CODE", "EPAYTEST")
ESEWA_SECRET_KEY = os.environ.get("ESEWA_SECRET_KEY", "")
ESEWA_PAYMENT_URL = os.environ.get(
        "ESEWA_EPAY_URL",
        "https://rc-epay.esewa.com.np/api/epay/main/v2/form"
    )

BACKEND_BASE_URL = "http://192.168.1.73:8000"  # change to your reachable backend URL


def generate_esewa_signature(secret_key: str, message: str) -> str:
    digest = hmac.new(
        secret_key.encode("utf-8"),
        message.encode("utf-8"),
        hashlib.sha256
    ).digest()
    return base64.b64encode(digest).decode("utf-8")


def initiate_esewa_payment(db: Session, booking_id: int, user_id: int) -> EsewaInitResponse:
    booking = db.query(Booking).filter(
        Booking.booking_id == booking_id,
        Booking.user_id == user_id
    ).first()

    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")
 
    if booking.status == "completed":
        raise HTTPException(status_code=400, detail="Booking already completed")

    amount = str(int(booking.total_price))
    tax_amount = "0"
    product_service_charge = "0"
    product_delivery_charge = "0"
    total_amount = str(
        int(amount) + int(tax_amount) + int(product_service_charge) + int(product_delivery_charge)
    )

    transaction_uuid = booking.transaction_uuid

    success_url = f"{BACKEND_BASE_URL}/bookings/esewa/success"
    failure_url = f"{BACKEND_BASE_URL}/bookings/esewa/failure"

    signed_field_names = "total_amount,transaction_uuid,product_code"

    message = (
        f"total_amount={total_amount},"
        f"transaction_uuid={transaction_uuid},"
        f"product_code={ESEWA_PRODUCT_CODE}"
    )

    signature = generate_esewa_signature(ESEWA_SECRET_KEY, message)

    form_data = {
        "amount": amount,
        "tax_amount": tax_amount,
        "total_amount": total_amount,
        "transaction_uuid": transaction_uuid,
        "product_code": ESEWA_PRODUCT_CODE,
        "product_service_charge": product_service_charge,
        "product_delivery_charge": product_delivery_charge,
        "success_url": success_url,
        "failure_url": failure_url,
        "signed_field_names": signed_field_names,
        "signature": signature,
    }

    return EsewaInitResponse(
        payment_url=ESEWA_PAYMENT_URL,
        form_data=form_data,
        booking_id=booking.booking_id,
        transaction_uuid=transaction_uuid,
    )


def handle_esewa_callback(db: Session, transaction_uuid: str, payment_status: str):
    booking = db.query(Booking).filter(
        Booking.transaction_uuid == transaction_uuid
    ).first()

    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found for transaction_uuid")

    was_completed = booking.status == "completed"

    if payment_status and payment_status.upper() == "COMPLETE":
        booking.status = "completed"
    else:
        booking.status = "failed"

    db.commit()
    db.refresh(booking)

    if booking.status == "completed" and not was_completed:
        referrals = (
            db.query(Referral)
            .filter(Referral.booking_id == booking.booking_id)
            .all()
        )
        if referrals:
            notify_friend_booking(
                db,
                booking=booking,
                referred_to_user_ids=[referral.referred_to for referral in referrals],
            )

    return booking
