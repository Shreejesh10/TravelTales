import enum
from app.utils.db_utils import Base
from sqlalchemy import Column, ForeignKey, Integer,Text,String, Enum ,DateTime, func
from sqlalchemy.dialects.postgresql import JSONB, ENUM as pgEnum
from sqlalchemy.orm import relationship

class UserRole(str, enum.Enum):
    CUSTOMER = "customer"
    COMPANY = "company"
    ADMIN = "admin"
    
class UserStatus(str, enum.Enum):
    PENDING = "pending"
    APPROVED = "approved"
    REJECTED = "rejected"
    SUSPENDED = "suspended"   
class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key= True, index = True)
    
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable= False)
    user_name = Column(String, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable= False)
    roles = Column(String, nullable =False , default= UserRole.CUSTOMER)
    status = Column( pgEnum(UserStatus,name="user_status",create_type=False, values_callable=lambda enum: [e.value for e in enum]), nullable=False, default=UserStatus.PENDING)
    # status = Column( pgEnum(UserStatus,name="user_status",create_type=False, native_enum = True), nullable=False, default=UserStatus.PENDING)

    
class Company(Base):
    __tablename__ = "companies"

    company_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False)
    
    company_name = Column(String(255), nullable=False)
    address = Column(Text, nullable=True)
    verified_at = Column(DateTime(timezone=True), nullable=True)  # NULL = pending, timestamp = approved

    user = relationship("User", backref="company") #done to navigate between company and user table without writing raw joints

class Destination(Base):
    __tablename__ = "destination"
    
    destination_id = Column(Integer, primary_key=True, index=True)
    place_name = Column(String(255), nullable=False, index=True)
    location = Column(String(255), nullable=False)
    description = Column(Text, nullable=False)
    extra_info = Column(JSONB, nullable=True)

class Genre(Base):
    __tablename__ = "genre"
    
    genre_id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False, unique=True, index=True)

class UserGenre(Base):
    __tablename__ = "user_genre"

    user_id = Column(Integer, ForeignKey('users.id',ondelete="CASCADE"), primary_key=True)
    genre_id = Column(Integer,ForeignKey('genre.genre_id', ondelete="CASCADE"),primary_key=True)
    value = Column(Integer, nullable = False, default= 0)
    
    # user = relationship("User", back_populates="user_genres")
    # genre = relationship("Genre", back_populates="user_genres")