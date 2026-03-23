from sqlalchemy.orm import Session
from sqlalchemy import or_
from typing import List, Optional
from app.model.models import Destination
from app.schemas.schemas import DestinationCreate, DestinationUpdate
from fastapi import UploadFile, HTTPException
import os
import uuid

    
def create_destination(db: Session, destination_data: DestinationCreate) -> Destination:
        extra_info_dict = destination_data.extra_info.dict() if destination_data.extra_info else {}
        
        db_destination = Destination(
            place_name=destination_data.place_name,
            location=destination_data.location,
            description=destination_data.description,
            extra_info=extra_info_dict
        )
        db.add(db_destination)
        db.commit()
        db.refresh(db_destination)
        return db_destination
    

def get_destination_by_id(db: Session, destination_id: int) -> Optional[Destination]:
        """Get a destination by ID"""
        return db.query(Destination).filter(Destination.destination_id == destination_id).first()

def get_all_destinations(db: Session):
       return db.query(Destination).all()


def delete_destination(db: Session, destination_id: int) -> bool:
        db_destination = get_destination_by_id(db, destination_id)
        
        if not db_destination:
            return False
        
        db.delete(db_destination)
        db.commit()
        return True

def search_destination(db: Session, query: str) -> List [Destination]:
          return (
        db.query(Destination)
        .filter(
            or_(
                Destination.place_name.ilike(f"%{query}%"),
                Destination.location.ilike(f"%{query}%"),
                Destination.description.ilike(f"%{query}%")
            )
        )
        .all()
    )

def update_destination_service(
    db: Session,
    destination_id: int,
    destination_update: DestinationUpdate
) -> Optional[Destination]:
    """Update a destination"""

    db_destination = get_destination_by_id(db, destination_id)
    if not db_destination:
        return None

    update_data = destination_update.model_dump(
        exclude_unset=True,
        exclude_none=True
    )


    if "extra_info" in update_data:
        extra_info_data = update_data["extra_info"]

        if hasattr(extra_info_data, "model_dump"):
            update_data["extra_info"] = extra_info_data.model_dump(
                exclude_unset=True,
                exclude_none=True
            )

    for field, value in update_data.items():
        setattr(db_destination, field, value)

    db.commit()
    db.refresh(db_destination)
    return db_destination
ALLOWED_IMAGE_TYPES = {
    "image/jpeg",
    "image/png",
    "image/webp",
    "image/jpg",
    "image/heic",
    "image/heif",
}

MAX_FILE_SIZE = 5 * 1024 * 1024  # 5MB


def _save_destination_image(photo: UploadFile, prefix: str, destination_id: int) -> str:
    if photo.content_type not in ALLOWED_IMAGE_TYPES:
        raise HTTPException(
            status_code=400,
            detail="Only jpg/png/webp/heif images allowed"
        )

    contents = photo.file.read()

    if len(contents) > MAX_FILE_SIZE:
        raise HTTPException(status_code=400, detail="Max file size is 5MB")

    ext = ".jpg"
    if photo.content_type == "image/png":
        ext = ".png"
    elif photo.content_type == "image/webp":
        ext = ".webp"
    elif photo.content_type in {"image/heic", "image/heif"}:
        ext = ".heic"

    os.makedirs("media/destinations", exist_ok=True)

    filename = f"{prefix}_{destination_id}_{uuid.uuid4().hex}{ext}"
    filepath = os.path.join("media/destinations", filename)

    with open(filepath, "wb") as f:
        f.write(contents)

    return f"/media/destinations/{filename}"


def upload_destination_backdrop_service(
    db: Session,
    destination_id: int,
    photo: UploadFile,
) -> Optional[Destination]:
    db_destination = get_destination_by_id(db, destination_id)
    if not db_destination:
        return None

    public_url = _save_destination_image(
        photo=photo,
        prefix="backdrop",
        destination_id=destination_id
    )

    extra_info = dict(db_destination.extra_info or {})
    extra_info["backdrop_path"] = [public_url]

    if "front_image_path" not in extra_info or extra_info["front_image_path"] is None:
        extra_info["front_image_path"] = []

    db_destination.extra_info = extra_info

    db.add(db_destination)
    db.commit()
    db.refresh(db_destination)
    return db_destination


def upload_destination_front_image_service(
    db: Session,
    destination_id: int,
    photo: UploadFile,
) -> Optional[Destination]:
    db_destination = get_destination_by_id(db, destination_id)
    if not db_destination:
        return None

    public_url = _save_destination_image(
        photo=photo,
        prefix="front",
        destination_id=destination_id
    )

    extra_info = dict(db_destination.extra_info or {})
    extra_info["front_image_path"] = [public_url]

    if "backdrop_path" not in extra_info or extra_info["backdrop_path"] is None:
        extra_info["backdrop_path"] = []

    db_destination.extra_info = extra_info

    db.add(db_destination)
    db.commit()
    db.refresh(db_destination)
    return db_destination