import logging
import os

from app.utils.db_utils import SessionLocal

logger = logging.getLogger(__name__)

try:
    from apscheduler.schedulers.background import BackgroundScheduler
except ImportError:  # pragma: no cover - optional dependency
    BackgroundScheduler = None


scheduler = None


def _run_tomorrow_reminders() -> None:
    from app.services.notification_service import send_tomorrow_booking_reminders

    db = SessionLocal()
    try:
        send_tomorrow_booking_reminders(db)
    except Exception:
        logger.exception("Tomorrow reminder job failed.")
    finally:
        db.close()


def start_scheduler() -> None:
    global scheduler

    if os.getenv("ENABLE_REMINDER_SCHEDULER", "true").lower() != "true":
        logger.info("Reminder scheduler is disabled.")
        return

    if BackgroundScheduler is None:
        logger.warning("apscheduler is not installed. Reminder scheduler is disabled.")
        return

    if scheduler and scheduler.running:
        return

    scheduler = BackgroundScheduler(timezone=os.getenv("REMINDER_TIMEZONE", "Asia/Kathmandu"))
    scheduler.add_job(
        _run_tomorrow_reminders,
        trigger="cron",
        hour=int(os.getenv("REMINDER_HOUR", "18")),
        minute=int(os.getenv("REMINDER_MINUTE", "0")),
        id="tomorrow-booking-reminders",
        replace_existing=True,
    )
    scheduler.start()
    logger.info("Reminder scheduler started.")


def stop_scheduler() -> None:
    global scheduler

    if scheduler and scheduler.running:
        scheduler.shutdown(wait=False)
        logger.info("Reminder scheduler stopped.")
