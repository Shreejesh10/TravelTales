from datetime import datetime
import enum
from app.utils.db_utils import Base
from sqlalchemy import Column, ForeignKey, Integer,Text,String, Enum ,DateTime, UniqueConstraint, func, Boolean, ARRAY, Time, Float
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
    has_completed_preference = Column(Boolean, default= False, nullable= False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable= False)
    roles = Column(String, nullable =False , default= UserRole.CUSTOMER)
    status = Column( pgEnum(UserStatus,name="user_status",create_type=False, values_callable=lambda enum: [e.value for e in enum]), nullable=False, default=UserStatus.PENDING)
    # status = Column( pgEnum(UserStatus,name="user_status",create_type=False, native_enum = True), nullable=False, default=UserStatus.PENDING)
    profile_picture_url = Column(String, nullable=True, default="/media/default/default_pp.png")
    fcm_token = Column(Text, nullable=True)
    reject_reason = Column(Text, nullable=True)

    bookings = relationship("Booking", back_populates="user", cascade="all, delete-orphan")
    referrals_made = relationship("Referral",foreign_keys="Referral.referred_by",back_populates="referrer",cascade="all, delete-orphan")
    referrals_received = relationship("Referral",foreign_keys="Referral.referred_to",back_populates="referred_user",cascade="all, delete-orphan")
    bookmarks = relationship("Bookmark", back_populates="user", cascade="all, delete-orphan")

    
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
    bookmarks = relationship("Bookmark", back_populates="destination", cascade="all, delete-orphan")

class Genre(Base):
    __tablename__ = "genre"
    
    genre_id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False, unique=True, index=True)

class UserGenre(Base):
    __tablename__ = "user_genre"

    user_id = Column(Integer, ForeignKey('users.id',ondelete="CASCADE"), primary_key=True)
    genre_id = Column(Integer,ForeignKey('genre.genre_id', ondelete="CASCADE"),primary_key=True)
    value = Column(Integer, nullable = False, default= 0)
    
class TravelEvent(Base):
    __tablename__ = "events"

    event_id = Column(Integer, primary_key=True, index= True)
    company_user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    destination_id = Column(Integer, ForeignKey("destination.destination_id"), nullable=False)

    title = Column(String(255), nullable=False)
    event_description = Column(Text, nullable=True)

    from_date = Column(DateTime, nullable=False)
    to_date = Column(DateTime, nullable= False )
    meeting_time = Column(Time, nullable=True)

    meeting_point = Column(String(255), nullable=True)
    what_to_bring = Column(ARRAY(String), nullable=True)

    max_people = Column(Integer, nullable=False)
    price = Column(Integer, nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable= False)
    is_closed = Column(Boolean, default=False, nullable=False)
    

    company = relationship("User")
    destination = relationship("Destination")
    bookings = relationship("Booking", back_populates="event", cascade="all, delete-orphan")

# Booking
class Booking(Base):
    __tablename__ = "bookings"

    booking_id = Column(Integer, primary_key=True, index=True) 
    transaction_uuid = Column(String(100), unique=True, nullable=False)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    event_id = Column(Integer, ForeignKey("events.event_id", ondelete="CASCADE"), nullable=False)

    total_price = Column(Float, nullable=False)
    booked_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    total_people = Column(Integer, nullable=False)

    # Pending Completed Faliure
    status = Column(String(20), nullable=False, server_default="pending")
    user = relationship("User", back_populates="bookings")
    event = relationship("TravelEvent", back_populates="bookings")
    referrals = relationship("Referral", back_populates="booking", cascade="all, delete-orphan")


class Referral(Base):
    __tablename__ = "referrals"

    referral_id = Column(Integer, primary_key=True, index=True)

    referred_by = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    referred_to = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)

    booking_id = Column(Integer, ForeignKey("bookings.booking_id", ondelete="CASCADE"), nullable=False) 

    booking = relationship("Booking", back_populates="referrals")

    referrer = relationship("User", foreign_keys=[referred_by], back_populates="referrals_made")
    referred_user = relationship("User", foreign_keys=[referred_to], back_populates="referrals_received")

class Friend(Base):
    __tablename__ = "friends"

    id = Column(Integer, primary_key=True, index=True)

    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    friend_user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)

    __table_args__ = (
        UniqueConstraint("user_id", "friend_user_id", name="uq_friend_pair"),
    )

    user = relationship("User", foreign_keys=[user_id], backref="friendships")
    friend_user = relationship("User", foreign_keys=[friend_user_id])


class FriendRequestStatus(str, enum.Enum):
    PENDING = "pending"
    ACCEPTED = "accepted"
    REJECTED = "rejected"


class FriendRequest(Base):
    __tablename__ = "friend_requests"

    id = Column(Integer, primary_key=True, index=True)

    sender_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    receiver_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)

    status = Column(pgEnum(FriendRequestStatus, name="friend_request_status", values_callable=lambda enum: [e.value for e in enum]),nullable=False,default=FriendRequestStatus.PENDING)
    created_at = Column(DateTime, default=datetime.utcnow)
    responded_at = Column(DateTime, nullable=True)

    __table_args__ = (
        UniqueConstraint("sender_id", "receiver_id", name="uq_friend_request_pair"),
    )

    sender = relationship("User", foreign_keys=[sender_id])
    receiver = relationship("User", foreign_keys=[receiver_id])

class Bookmark(Base):
    __tablename__ = "bookmarks"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    destination_id = Column(Integer, ForeignKey("destination.destination_id", ondelete="CASCADE"), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable= False)

    __table_args__ = (
        UniqueConstraint("user_id", "destination_id", name="unique_user_destination_bookmark"),
    )

    user = relationship("User", back_populates="bookmarks")
    destination = relationship("Destination", back_populates="bookmarks")
