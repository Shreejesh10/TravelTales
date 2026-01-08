from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from app.utils.db_utils import get_db
from app.services.destination_service import (
    create_destination as db_create_destination, 
    get_destination_by_id, 
    get_all_destinations, 
    delete_destination)


from app.schemas.schemas import(
    DestinationResponse,
    DestinationCreate,
    DestinationUpdate
)

_SHOW_NAME = "destinations"
router = APIRouter(
    prefix=f'/{_SHOW_NAME}',
    tags=[_SHOW_NAME],
    responses={404: {'description': 'Not found'}}
)

@router.post("/", response_model= DestinationResponse, status_code= status.HTTP_201_CREATED)
def create_destination(
    destination : DestinationCreate,
    db: Session = Depends(get_db)
):
    try: 
        new_destination = db_create_destination(db, destination)
        return new_destination
    except Exception as e:
        raise HTTPException(
            status_code= status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail = f"error went Creating destination:{str(e)}"
        )


@router.get("/", response_model=List[DestinationResponse])
def get_all_destination_route(
    db: Session = Depends(get_db)
):
    try:
        destinations = get_all_destinations(db)
        if destinations is None:
            return []
        return destinations 

    except Exception:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal Server Error"
        )


@router.get("/{destination_id}", response_model=DestinationResponse)
def get_destination_id(
    destination_id: int,
    db: Session = Depends(get_db)
):
    try:
        destination = get_destination_by_id(db, destination_id)

        if not destination:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Destination with id {destination_id} not found"
            )

        return destination

    except HTTPException:
        raise  

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An unexpected error occurred"
        )

@router.delete("/{destination_id}", status_code= status.HTTP_204_NO_CONTENT)
def delete_destination_route(
    destination_id: int,
    db: Session = Depends(get_db)
):
    try:
        destination = delete_destination(db, destination_id)

        if not destination: 
            raise HTTPException(
                status_code= status.HTTP_404_NOT_FOUND,
                detail=f"Destination with id {destination_id} not found"
            )
        return destination
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An unexpected error occurred"
        ) 