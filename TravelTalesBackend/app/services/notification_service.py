import json
import logging
import os
from typing import Iterable

from sqlalchemy.orm import Session

from app.model.models import Booking, TravelEvent, User

logger = logging.getLogger(__name__)

try:
    import firebase_admin
    from firebase_admin import credentials, messaging
except ImportError:  # pragma: no cover - optional dependency
    firebase_admin = None
    credentials = None
    messaging = None


_firebase_initialized = False


def _initialize_firebase() -> bool:
    global _firebase_initialized

    if _firebase_initialized:
        return True

    if firebase_admin is None:
        logger.warning("firebase_admin is not installed. Skipping push notifications.")
        return False

    if firebase_admin._apps:
        _firebase_initialized = True
        return True

    credential_path = os.getenv("FIREBASE_CREDENTIALS_PATH")
    credential_json = os.getenv("FIREBASE_CREDENTIALS_JSON")

    try:
        if credential_json:
            credential_info = json.loads(credential_json)
            firebase_admin.initialize_app(credentials.Certificate(credential_info))
        elif credential_path and os.path.exists(credential_path):
            firebase_admin.initialize_app(credentials.Certificate(credential_path))
        else:
            logger.warning(
                "Firebase credentials are not configured. Set FIREBASE_CREDENTIALS_PATH "
                "or FIREBASE_CREDENTIALS_JSON to enable notifications."
            )
            return False
    except Exception:
        logger.exception("Failed to initialize Firebase Admin SDK.")
        return False

    _firebase_initialized = True
    return True


def _clean_tokens(tokens: Iterable[str | None]) -> list[str]:
    seen: set[str] = set()
    cleaned: list[str] = []

    for token in tokens:
        if not token:
            continue
        normalized = token.strip()
        if not normalized or normalized in seen:
            continue
        seen.add(normalized)
        cleaned.append(normalized)

    return cleaned


def send_push_notification_to_tokens(
    tokens: list[str],
    title: str,
    body: str,
    data: dict[str, str] | None = None,
) -> int:
    if not tokens:
        logger.info("Skipping push notification because there are no target tokens.")
        return 0

    if not _initialize_firebase():
        logger.warning(
            "Skipping push notification because Firebase Admin is not ready."
        )
        return 0

    data = {key: str(value) for key, value in (data or {}).items()}
    success_count = 0

    for start in range(0, len(tokens), 500):
        batch = tokens[start:start + 500]
        message = messaging.MulticastMessage(
            tokens=batch,
            notification=messaging.Notification(title=title, body=body),
            data=data,
        )

        try:
            response = messaging.send_each_for_multicast(message)
            success_count += response.success_count
            logger.info(
                "Push batch sent: %s success, %s failure.",
                response.success_count,
                response.failure_count,
            )

            invalid_tokens = [
                batch[index]
                for index, result in enumerate(response.responses)
                if not result.success and getattr(result.exception, "code", None) in {
                    "registration-token-not-registered",
                    "invalid-argument",
                }
            ]
            if invalid_tokens:
                logger.info("FCM rejected %s token(s).", len(invalid_tokens))
        except Exception:
            logger.exception("Failed to send multicast push notification.")

    return success_count


def notify_new_event(db: Session, event: TravelEvent) -> int:
    users = (
        db.query(User)
        .filter(
            User.id != event.company_user_id,
            User.fcm_token.isnot(None),
        )
        .all()
    )
    tokens = _clean_tokens(user.fcm_token for user in users)
    logger.info(
        "Preparing new event notification for event_id=%s with %s target token(s).",
        event.event_id,
        len(tokens),
    )

    sent_count = send_push_notification_to_tokens(
        tokens=tokens,
        title="New Travel Event",
        body=f"{event.title} a new travel event has just been dropped.",
        data={
            "type": "event",
            "event_id": event.event_id,
            "destination_id": event.destination_id,
        },
    )
    logger.info(
        "New event notification finished for event_id=%s with %s successful send(s).",
        event.event_id,
        sent_count,
    )
    return sent_count


def send_tomorrow_booking_reminders(db: Session) -> int:
    from datetime import datetime, time, timedelta

    tomorrow = datetime.now().date() + timedelta(days=1)
    start_of_day = datetime.combine(tomorrow, time.min)
    end_of_day = datetime.combine(tomorrow, time.max)

    bookings = (
        db.query(Booking)
        .join(Booking.event)
        .join(Booking.user)
        .filter(
            Booking.status == "completed",
            User.fcm_token.isnot(None),
            TravelEvent.from_date >= start_of_day,
            TravelEvent.from_date <= end_of_day,
        )
        .all()
    )

    sent_count = 0
    for booking in bookings:
        sent_count += send_push_notification_to_tokens(
            tokens=_clean_tokens([booking.user.fcm_token]),
            title="Trip Reminder",
            body=f"Your trip for {booking.event.title} starts tomorrow.",
            data={
                "type": "booking_reminder",
                "booking_id": booking.booking_id,
                "event_id": booking.event_id,
            },
        )

    logger.info("Sent %s tomorrow reminder notification(s).", sent_count)
    return sent_count
