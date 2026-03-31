from sqlalchemy.orm import Session, joinedload
from app.model.models import Bookmark, Destination


def get_bookmark(db: Session, user_id: int, destination_id: int):
    return (
        db.query(Bookmark)
        .filter(
            Bookmark.user_id == user_id,
            Bookmark.destination_id == destination_id
        )
        .first()
    )


def create_bookmark(db: Session, user_id: int, destination_id: int):
    existing = get_bookmark(db, user_id, destination_id)
    if existing:
        return existing, False

    destination = db.query(Destination).filter(Destination.destination_id == destination_id).first()
    if not destination:
        return None, None

    bookmark = Bookmark(
        user_id=user_id,
        destination_id=destination_id
    )
    db.add(bookmark)
    db.commit()
    db.refresh(bookmark)
    return bookmark, True


def delete_bookmark(db: Session, user_id: int, destination_id: int):
    bookmark = get_bookmark(db, user_id, destination_id)
    if not bookmark:
        return None

    db.delete(bookmark)
    db.commit()
    return bookmark


def get_user_bookmarks(db: Session, user_id: int):
    return (
        db.query(Bookmark)
        .options(joinedload(Bookmark.destination))
        .filter(Bookmark.user_id == user_id)
        .order_by(Bookmark.created_at.desc())
        .all()
    )

def get_user_bookmarked_destinations(db: Session, user_id: int):
    bookmarks = get_user_bookmarks(db, user_id)
    return [bookmark.destination for bookmark in bookmarks if bookmark.destination]