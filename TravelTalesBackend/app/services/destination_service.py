from sqlalchemy.orm import Session
from sqlalchemy import or_
from typing import List, Optional
from app.model.models import Destination
from app.schemas.schemas import DestinationCreate


    
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

