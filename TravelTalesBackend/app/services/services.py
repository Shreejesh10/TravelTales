from app.model.models import User
from sqlalchemy.orm import Session
from app.schemas.schemas import UserCreate
from app.utils.hashing import hash_password
from app.utils.hashing import verify_password

def create_user(db: Session, data: UserCreate):
    # for hashing password hash password before saving
    user_data = data.model_dump()
    user_data["hashed_password"] = hash_password(user_data.pop("password"))

    user_instance = User(**user_data)
    db.add(user_instance)
    db.commit()
    db.refresh(user_instance)
    return user_instance


def get_users(db: Session):
    return db.query(User).all()


def get_user_by_email(db: Session, email: str):
    return db.query(User).filter(User.email == email).first()

def authenticate_user(db: Session, email: str, password: str):
    user = db.query(User).filter(User.email == email).first()

    if not user:
        return None

    if not verify_password(password, user.hashed_password):
        return None

    return user

