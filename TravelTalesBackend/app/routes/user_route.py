from app.auth.auth import get_current_user
from app.model.models import User
from app.utils.hashing import hash_password, verify_password
from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
import os
import uuid
from app.utils.db_utils import get_db
from app.model import *
from sqlalchemy.orm import Query, Session
from app.schemas.schemas import ChangePassword, LoginResponse, UserCreate, UserLogin, UserResponse, UserUpdate
from app.services.services import create_user, authenticate_user, fetch_user_information, search_users_by_name
from app.utils.jwt_util import create_access_token, create_refresh_token
from pathlib import Path
from fastapi import Query


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
    
    if authenticated_user.roles == "company" and authenticated_user.status != "approved":
        if authenticated_user.status == "pending":
            reason = "Your registration request is still pending. Please wait while we review your request."
        else:
            reject_reason = authenticated_user.reject_reason or "Please contact us for further details."
            reason = f"Your registration request has been rejected. {reject_reason}"
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=reason
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
        roles=  authenticated_user.roles,
        has_completed_preference= authenticated_user.has_completed_preference
    )


@router.get("/me/user_information", response_model=UserResponse)
def get_user_information_route(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    user = fetch_user_information(db, current_user.id)

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    return user

@router.get("/search-users")
def search_users_endpoint(
    query: str = Query(...),
    current_users: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    users = search_users_by_name(db, query)

    return [
        {
            "id": user.id,
            "user_name": user.user_name,
            "email": user.email,
            "role": user.roles,
            "status": user.status,
             "profile_picture_url": user.profile_picture_url,
        }
        for user in users
    ]

@router.get("/id/{user_id}", response_model=UserResponse)
def get_user_by_id(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user
    
@router.post("/me/profile_photo")
def upload_profile_photo(
    photo: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    allowed = {"image/jpeg", "image/png", "image/webp", "image/jpg", "image/heic", "image/heif"}
    print("CONTENT TYPE:", photo.content_type)
    print("FILENAME:", photo.filename)
    if photo.content_type not in allowed:
        raise HTTPException(status_code=400, detail="Only jpg/png/webp/heif images allowed")

    contents = photo.file.read()
    if len(contents) > 5 * 1024 * 1024:
        raise HTTPException(status_code=400, detail="Max file size is 5MB")

    ext = ".jpg"
    if photo.content_type == "image/png":
        ext = ".png"
    elif photo.content_type == "image/webp":
        ext = ".webp"
    elif photo.content_type in {"image/heic", "image/heif"}:
        ext = ".heic"
    from pathlib import Path
    print("CWD:", os.getcwd())
    print("BASE DIR:", Path(__file__).resolve().parent)

    os.makedirs("media/profile_photos", exist_ok=True)
    filename = f"user_{current_user.id}_{uuid.uuid4().hex}{ext}"
    filepath = os.path.join("media/profile_photos", filename)

    with open(filepath, "wb") as f:
        f.write(contents)

    public_url = f"/media/profile_photos/{filename}"

    current_user.profile_picture_url = public_url

    db.add(current_user)
    db.commit()
    db.refresh(current_user)

    return {"profile_picture_url": public_url}

@router.put("/me/update")
def update_user_information(
    user_update: UserUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    if user_update.email and user_update.email != current_user.email:
        existing_email_user = db.query(User).filter(User.email == user_update.email).first()
        if existing_email_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email already in use by another account."
            )
    
    if user_update.user_name and user_update.user_name != current_user.user_name:
        existing_username_user = db.query(User).filter(User.user_name == user_update.user_name).first()
        if existing_username_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Username already taken by another account."
            )
    
    if user_update.user_name:
        current_user.user_name = user_update.user_name
    if user_update.email:
        current_user.email = user_update.email

    db.add(current_user)
    db.commit()
    db.refresh(current_user)

    return current_user


@router.put("/me/change-password")
def change_password(
    data: ChangePassword,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    if not verify_password(data.current_password, current_user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Current password is incorrect"
        )

    if verify_password(data.new_password, current_user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="New password must be different from current password"
        )

    current_user.hashed_password = hash_password(data.new_password)

    db.add(current_user)
    db.commit()
    db.refresh(current_user)

    return {
        "message": "Password changed successfully"
    }