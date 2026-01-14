from fastapi import Depends, HTTPException, status
from jose import JWTError, jwt
from sqlalchemy.orm import Session
import os

from app.utils.db_utils import get_db
from app.model.models import User
from app.utils.oauth2 import security
from fastapi.security import HTTPAuthorizationCredentials
from app.utils.jwt_util import create_access_token



SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = os.getenv("ALGORITHM")

def get_current_user(
        credentials: HTTPAuthorizationCredentials  = Depends(security),
        db : Session = Depends(get_db)
):
    token = credentials.credentials
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: int = int(payload.get("sub"))
        email: str = payload.get("email")
        if user_id is None or email is None:
            raise HTTPException(status_code=401, detail="Invalid token")
    except JWTError as e:
        print("an error occured", str(e))
        raise HTTPException(status_code=401, detail="Invalid token")

    user = db.query(User).filter(User.email == email).first()
    if not user:
        raise HTTPException(status_code=401, detail="User not found")

    return user

def refresh_token(token: str):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])

        if payload.get("type") != "refresh":
            raise HTTPException(status_code=401, detail="Invalid token type")

        email: str = payload.get("sub")
        if not email:
            raise HTTPException(status_code=401, detail="Invalid token")

        new_access_token = create_access_token({"sub": email})

        return {
            "access_token": new_access_token,
            "token_type": "bearer"
        }

    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid or expired refresh token")