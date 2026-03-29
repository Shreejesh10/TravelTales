from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List
import base64
import json

from app.utils.db_utils import get_db
from app.auth.auth import get_current_user
from app.schemas.schemas import BookingCreate, BookingResponse, EsewaInitResponse
from app.services.booking_service import (
    create_booking,
    get_my_bookings,
    get_booking_by_id,
    initiate_esewa_payment,
    handle_esewa_callback,
)
from app.model.models import User

router = APIRouter(prefix="/bookings", tags=["Bookings"])


@router.post("/", response_model=BookingResponse)
def book_event(
    booking_data: BookingCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return create_booking(db, current_user.id, booking_data)


@router.get("/esewa/success")
def esewa_success(
    data: str | None = Query(None),
    db: Session = Depends(get_db)
):
    try:
        if not data:
            raise HTTPException(status_code=400, detail="Missing eSewa response data")

        payload = base64.b64decode(data).decode("utf-8")
        payment_data = json.loads(payload)

        transaction_uuid = payment_data.get("transaction_uuid")
        payment_status = payment_data.get("status")

        if not transaction_uuid:
            raise HTTPException(status_code=400, detail="Missing transaction_uuid")

        booking = handle_esewa_callback(db, transaction_uuid, payment_status)

        return {
            "message": "eSewa callback handled successfully",
            "booking_id": booking.booking_id,
            "status": booking.status,
            "esewa_status": payment_status,
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid eSewa success response: {str(e)}"
        )


@router.get("/esewa/failure")
def esewa_failure():
    return {
        "message": "Payment failed or cancelled"
    }


@router.get("/my", response_model=List[BookingResponse])
def my_bookings(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return get_my_bookings(db, current_user.id)


@router.post("/{booking_id}/esewa", response_model=EsewaInitResponse)
def pay_booking_with_esewa(
    booking_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return initiate_esewa_payment(db, booking_id, current_user.id)


@router.get("/{booking_id}", response_model=BookingResponse)
def booking_detail(
    booking_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    booking = get_booking_by_id(db, booking_id, current_user.id)
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")
    return booking