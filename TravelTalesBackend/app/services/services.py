from datetime import datetime
from app.model.models import Company, User, UserStatus
from sqlalchemy.orm import Session
from app.schemas.schemas import CompanyCreate, UserCreate
from app.utils.hashing import hash_password
from app.utils.hashing import verify_password

def create_user(db: Session, data: UserCreate):
    # for hashing password hash password before saving
    existing_user = get_user_by_email(db, data.email)
    if existing_user:
        raise ValueError("Account already exists")
    user_data = data.model_dump()
    user_data["hashed_password"] = hash_password(user_data.pop("password"))

    if user_data.get("roles") == "company":
        user_data["status"] = UserStatus.PENDING

    user_instance = User(**user_data)
    db.add(user_instance)
    db.commit()
    db.refresh(user_instance)

    initialize_user_genres(db, user_instance.id)
    return user_instance


# def get_users(db: Session):
#     return db.query(User).all()


def get_user_by_email(db: Session, email: str):
    return db.query(User).filter(User.email == email).first()

def authenticate_user(db: Session, email: str, password: str):
    user = db.query(User).filter(User.email == email).first()

    if not user:
        return None

    if not verify_password(password, user.hashed_password):
        return None

    return user

def initialize_user_genres(db: Session, user_id: int):
    """Initialize all genres to 0 for new user"""
    from app.model.models import Genre, UserGenre
    
    all_genres = db.query(Genre).all()
    
    for genre in all_genres:
        user_genre = UserGenre(
            user_id=user_id,
            genre_id=genre.genre_id,
            value=0 
        )
        db.add(user_genre)
    
    db.commit()

def create_company(db:Session, data: CompanyCreate):
    user = db.query(User).filter(User.id == data.user_id, User.roles =="company").first()

    if not user:
        raise ValueError("Invalid company user")

    # Ensure company row doesn't exist yet
    existing = db.query(Company).filter(Company.user_id == data.user_id).first()
    if existing:
        raise ValueError("Company already exists")

    company_instance = Company(
        user_id=data.user_id,
        company_name=data.company_name,
        address=data.address
    )
    db.add(company_instance)
    db.commit()
    db.refresh(company_instance)
    return company_instance

def get_company_by_user_id(db: Session, user_id: int):
    return db.query(Company).filter(Company.user_id == user_id).first()

def get_company_by_id(db: Session, company_id: int):
    return db.query(Company).filter(Company.company_id == company_id).first()

def list_pending_companies(db: Session):
    """Return all companies whose users are pending approval"""
    return db.query(Company).join(User).filter(User.roles == "company", User.status == UserStatus.PENDING).all()

def approve_or_reject_company(db: Session, user_id: int, approve: bool):
    """Admin approves or rejects a company"""
    user = db.query(User).filter(User.id == user_id, User.roles == "company").first()
    if not user:
        raise ValueError("Company user not found")

    company = db.query(Company).filter(Company.user_id == user_id).first()
    if not company:
        # Create company row if it doesn't exist yet
        company_data = CompanyCreate(user_id=user.id, company_name="Unknown")  # or pass name separately

        company = create_company(db, company_data)

    if approve:
        user.status = UserStatus.APPROVED
        company.verified_at = datetime.utcnow()
        message = "Company approved"
    else:
        user.status = UserStatus.REJECTED
        company.verified_at = None
        message = "Company rejected"

    db.commit()
    db.refresh(user)
    db.refresh(company)
    return {"user_id": user.id, "company_id": company.company_id, "status": user.status, "message": message}