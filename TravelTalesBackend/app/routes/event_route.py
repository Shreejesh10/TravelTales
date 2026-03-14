from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.auth.auth import get_current_user
from app.model.models import User
from app.utils.db_utils import get_db

from app.schemas.schemas import TravelEventResponse, TravelEventCreate, TravelEventUpdate
from app.services.event_service import create_event, get_company_events, delete_event, update_event, get_event_by_id, get_all_events

_SHOW_NAME = "events"
router = APIRouter(
    prefix=f"/{_SHOW_NAME}",
    tags=[_SHOW_NAME],
    responses={404: {"description": "Not found"}}
)

@router.post("/", response_model=TravelEventResponse, status_code=status.HTTP_201_CREATED)
def create_event_route(
    event_data: TravelEventCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if current_user.roles != "company":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only company users can create events"
        )

    if current_user.status != "approved":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only approved companies can create events"
        )

    try:
        return create_event(db, current_user.id, event_data)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    
@router.get("/all", response_model=List[TravelEventResponse])
def get_all_events_route(
    db: Session = Depends(get_db),
):
    try:
        return get_all_events(db)
    except ValueError as e:
        raise HTTPException(
            status_code= status.HTTP_400_BAD_REQUEST,
            detail= str(e)
        )

@router.get("/me", response_model=List[TravelEventResponse])
def get_my_events(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if current_user.roles != "company":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only company users can view their events"
        )

    return get_company_events(db, current_user.id)


@router.get("/{event_id}", response_model=TravelEventResponse)
def get_single_event(
    event_id: int,
    db: Session = Depends(get_db),
):
    event = get_event_by_id(db, event_id)

    if not event:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Event not found"
        )

    return event


@router.patch("/{event_id}", response_model=TravelEventResponse)
def update_event_route(
    event_id: int,
    event_data: TravelEventUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if current_user.roles != "company":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only company users can update events"
        )

    updated_event = update_event(db, event_id, current_user.id, event_data)

    if not updated_event:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Event not found or you do not have permission"
        )

    return updated_event

@router.delete("/{event_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_event_route(
    event_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if current_user.roles != "company":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only company users can delete events"
        )

    deleted = delete_event(db, event_id, current_user.id)

    if not deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Event not found or you do not have permission"
        )