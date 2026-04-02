from sqlalchemy.orm import Session, joinedload
from app.schemas.schemas import TravelEventCreate, TravelEventUpdate
from app.model.models import TravelEvent, Destination
from typing import List, Optional
from app.services.notification_service import notify_new_event


def create_event(db: Session, company_user_id: int, event_data: TravelEventCreate) -> TravelEvent:
    destination = db.query(Destination).filter(
        Destination.destination_id == event_data.destination_id
    ).first()

    if not destination:
        raise ValueError("Destination not found")
    
    db_event = TravelEvent(
        company_user_id=company_user_id,
        destination_id=event_data.destination_id,
        title=event_data.title,
        event_description=event_data.event_description,
        meeting_time = event_data.meeting_time,
        to_date=event_data.to_date,
        from_date=event_data.from_date,
        meeting_point=event_data.meeting_point,
        what_to_bring=event_data.what_to_bring,
        max_people=event_data.max_people,
        price=event_data.price,
    )
    db.add(db_event)
    db.commit()
    db.refresh(db_event)
    notify_new_event(db, db_event)
    return db_event


def get_company_events(db: Session, company_user_id: int) -> List[TravelEvent]:
    return (
        db.query(TravelEvent)
        .options(joinedload(TravelEvent.destination))
        .filter(TravelEvent.company_user_id == company_user_id)
        .all()
    )

def update_event(db: Session, event_id: int, company_user_id: int, event_data: TravelEventUpdate) -> Optional[TravelEvent]:
    db_event = db.query(TravelEvent).filter(
        TravelEvent.event_id == event_id,
        TravelEvent.company_user_id == company_user_id
    ).first()

    if not db_event:
        return None

    update_data = event_data.model_dump(exclude_unset=True, exclude_none=True)

    for field, value in update_data.items():
        setattr(db_event, field, value)

    db.commit()
    db.refresh(db_event)
    return db_event

def delete_event(db: Session, event_id: int, company_user_id: int) -> bool:
    db_event = db.query(TravelEvent).filter(
        TravelEvent.event_id == event_id,
        TravelEvent.company_user_id == company_user_id
    ).first()

    if not db_event:
        return False

    db.delete(db_event)
    db.commit()
    return True

def get_event_by_id(db: Session, event_id: int) -> Optional[TravelEvent]:
    return (
        db.query(TravelEvent)
        .options(joinedload(TravelEvent.destination))
        .filter(TravelEvent.event_id == event_id)
        .first()
    )

def get_all_events(db: Session) -> List[TravelEvent]:
    return (
        db.query(TravelEvent)
        .options(joinedload(TravelEvent.destination))
        .order_by(TravelEvent.from_date.asc())
        .all()
    )
