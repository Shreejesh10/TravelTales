from fastapi import APIRouter, Depends, HTTPException, status
from app.utils.db_utils import get_db
from app.model import *
from sqlalchemy.orm import Session
from app.schemas.schemas import LoginResponse, UserCreate, UserLogin, UserResponse
from app.services.services import create_user, authenticate_user
from app.utils.jwt_util import create_access_token, create_refresh_token


_SHOW_NAME = "users"
router = APIRouter(
    prefix=f'/{_SHOW_NAME}',
    tags=[_SHOW_NAME],
    responses={404:{'description': 'Not found'}}
)

@router.post('/signup', response_model=UserResponse, status_code=status.HTTP_201_CREATED)
def signup(user:UserCreate, db: Session = Depends(get_db)):
    try:
        return create_user(db, user)
    except ValueError as e:
        raise HTTPException (
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
@router.post("/login", response_model= LoginResponse)
def login(user: UserLogin, db: Session = Depends(get_db)):
    authenticated_user = authenticate_user(db, user.email, user.password)

    if not authenticated_user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password"
        )
    access_token = create_access_token(
        data= {
            "sub": str(authenticated_user.id),
            "email": authenticated_user.email  
        }
    )
    refresh_token = create_refresh_token(
        data= {
            "sub": str(authenticated_user.id),
            "email": authenticated_user.email  
        }
    )

    return LoginResponse(
        user_id=authenticated_user.id,
        access_token=access_token,
        refresh_token=refresh_token,
        message="Login successful",
        roles=  authenticated_user.roles
    )




