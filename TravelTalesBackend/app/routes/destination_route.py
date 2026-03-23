from typing import List, Optional
from app.auth.auth import get_current_user
from app.model.models import User
from fastapi.exceptions import RequestValidationError
from fastapi import APIRouter, Depends, HTTPException, Query, status, UploadFile, File
from sqlalchemy.orm import Session
from app.utils.db_utils import get_db
from app.services.destination_service import (
    create_destination as db_create_destination, 
    get_destination_by_id, 
    get_all_destinations, 
    delete_destination,
    update_destination_service,
    search_destination, 
    upload_destination_backdrop_service,
    upload_destination_front_image_service)
from app.services.recommendation_service import recommend_destinations


from app.schemas.schemas import(
    DestinationResponse,
    DestinationCreate,
    DestinationUpdate
)
import os, uuid

_SHOW_NAME = "destinations"
router = APIRouter(
    prefix=f'/{_SHOW_NAME}',
    tags=[_SHOW_NAME],
    responses={404: {'description': 'Not found'}}
)

@router.post("/", response_model= DestinationResponse, status_code= status.HTTP_201_CREATED)
def create_destination(
    destination : DestinationCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if current_user.roles != "admin":
        raise HTTPException(
            status_code= status.HTTP_403_FORBIDDEN,
            detail= "Only admin can create new destination"
        )
    try: 
        new_destination = db_create_destination(db, destination)
        return new_destination
    except RequestValidationError as ve:
        raise HTTPException(
            status_code= status.HTTP_400_BAD_REQUEST,
            detail= ve.errors()
        )
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

@router.get("/search-destination")
def search_destination_route(
    query: str, 
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
    ):
    return search_destination(db, query)

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
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    
    if current_user.roles != "admin":
        raise HTTPException(
            status_code= status.HTTP_403_FORBIDDEN,
            detail= "Only admin can delete destination"
        )
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

@router.patch("/{destination_id}", response_model = DestinationResponse)
def update_destination(
    destination_update: DestinationUpdate,
    destination_id : int,
    current_user : User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    if current_user.roles != "admin":
        raise HTTPException(
            status_code = status.HTTP_403_FORBIDDEN,
            detail= "Only admin is allowed to update the information"
        )
    update_destination = update_destination_service(
        db, destination_id, destination_update
    )
    if not update_destination:
        raise HTTPException(
            status_code= status.HTTP_404_NOT_FOUND,
            detail= f"Destination with id {destination_id} not found"
        )
    return update_destination




@router.get("/recommend/me", response_model=List[DestinationResponse])
def get_recommendations(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return recommend_destinations(db, current_user.id)

@router.post("/{destination_id}/upload-backdrop", response_model=DestinationResponse)
def upload_destination_backdrop(
    destination_id: int,
    photo: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    
    if current_user.roles != "admin":
        raise HTTPException(status_code=403, detail="Only admin can upload destination images")

    destination = upload_destination_backdrop_service(
        db=db,
        destination_id=destination_id,
        photo=photo,
    )

    if not destination:
        raise HTTPException(status_code=404, detail="Destination not found")

    return destination


@router.post("/{destination_id}/upload-front-image", response_model=DestinationResponse)
def upload_destination_front_image(
    destination_id: int,
    photo: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    
    if current_user.roles != "admin":
        raise HTTPException(status_code=403, detail="Only admin can upload destination images")

    destination = upload_destination_front_image_service(
        db=db,
        destination_id=destination_id,
        photo=photo,
    )

    if not destination:
        raise HTTPException(status_code=404, detail="Destination not found")

    return destination