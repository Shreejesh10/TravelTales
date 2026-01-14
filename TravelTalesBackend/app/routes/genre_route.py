from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.utils.db_utils import get_db
from app.schemas.schemas import (
    PreferenceRequest,
    UserPreferencesResponse
)
from app.services.genre_service import (
    update_user_preferences,
    get_user_preferences,
)
from app.auth.auth import get_current_user
from app.model.models import User

router = APIRouter(
    prefix="/users",
    tags=["user-preferences"]
)

@router.post('/update_preferences/me')
def update_preferences(
    data: PreferenceRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):

    try:
        user_id = current_user.id

        genre_ids = data.preferences.genre_ids
        update_user_preferences(db, user_id, genre_ids)
        
        return {"message": "Success: Preference Updated Successfully"}
    
    except Exception as e:
        print(str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error: {str(e)}"
        )


@router.get('/get_preferences/me', response_model=UserPreferencesResponse)
def get_preferences(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    try:
        user_id = current_user.id
        preferences = get_user_preferences(db, user_id)
        
        if not preferences:
            return {"preferences": []}
        
        return {"preferences": preferences}
    
    except Exception as e:
        print(str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error: {str(e)}"
        )

        # role = current_user.role
        # if (role != "admin"):
        #     return HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=)