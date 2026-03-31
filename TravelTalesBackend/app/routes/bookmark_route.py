from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.utils.db_utils import get_db
from app.schemas.schemas import BookmarkCreate, BookmarkResponse, DestinationResponse
from app.services.bookmark_service import (
    create_bookmark,
    delete_bookmark,
    get_user_bookmarked_destinations,
    get_bookmark,
)
from app.auth.auth import get_current_user
from app.model.models import User

router = APIRouter(prefix="/bookmarks", tags=["Bookmarks"])


@router.post("/", response_model=BookmarkResponse)
def add_bookmark(
    data: BookmarkCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    bookmark, created = create_bookmark(db, current_user.id, data.destination_id)

    if bookmark is None and created is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Destination not found"
        )

    return bookmark


@router.delete("/{destination_id}")
def remove_bookmark(
    destination_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    bookmark = delete_bookmark(db, current_user.id, destination_id)

    if not bookmark:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Bookmark not found"
        )

    return {"message": "Bookmark removed successfully"}


@router.get("/", response_model=list[DestinationResponse])
def list_bookmarks(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return get_user_bookmarked_destinations(db, current_user.id)


@router.get("/check/{destination_id}")
def check_bookmark(
    destination_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    bookmark = get_bookmark(db, current_user.id, destination_id)
    return {"bookmarked": bookmark is not None}