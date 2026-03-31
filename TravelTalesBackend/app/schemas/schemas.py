from pydantic import BaseModel, EmailStr, Field, field_validator
from datetime import datetime, time
from typing import Literal, Optional, List, Dict, Any
from app.model.models import UserStatus

class UserCreate(BaseModel):
    email: EmailStr
    password: str 
    user_name: Optional[str] = None
    roles: Literal["company", "customer"] = "customer"
    

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class LoginResponse(BaseModel):
    user_id: int
    access_token: str
    refresh_token: str
    message: str
    roles: str
    has_completed_preference: bool

class UserResponse(BaseModel):
    id: int
    email: EmailStr
    user_name: Optional[str] = None
    created_at: datetime
    roles: str
    status: UserStatus
    profile_picture_url: Optional[str] = None
    class Config:
        
        from_attributes = True  
class UserUpdate(BaseModel):
    user_name: Optional[str] = None
    email: EmailStr

class ChangePassword(BaseModel):
    current_password: str
    new_password: str

#Company
class CompanyBase(BaseModel):
    company_name: str
    address: Optional[str] = None

class CompanyCreate(CompanyBase):
    user_id: int
    status_tag: UserStatus

class CompanyResponse(BaseModel):
    company_id: int
    user_id: int
    company_name: str
    address: Optional[str] = None
    verified_at: Optional[datetime] = None

    class Config:
        from_attributes = True

class PendingCompanyResponse(BaseModel):
    user_id: int
    email: str
    user_name: Optional[str] = None
    registered_at: datetime

class RejectRequest(BaseModel):
    reason: Optional[str] = None

class CompanyApprovalResponse(BaseModel):
    user_id: int
    company_id: Optional[int] = None
    status: UserStatus
    message: str

class DestinationExtraInfo(BaseModel):
    highlights: Optional[List[str]] = []
    attractions: Optional[List[str]] = []
    best_time_to_visit: Optional[str] = None
    transportation: Optional[str] = None
    accommodation: Optional[str] = None
    safety_tips: Optional[List[str]] = []
    photos: Optional[List[str]] = []
    genre_vector: Optional[List[int]] = []

    difficulty_level: Optional[str] = None
    duration: Optional[str] = None
    elevation: Optional[List[int]] = []
    backdrop_path: Optional[List[str]] = []
    front_image_path: Optional[List[str]] = []

    @field_validator('safety_tips', mode='before')
    @classmethod
    def convert_safety_tips_to_list(cls, v):
        if v is None:
            return []
        if isinstance(v, str):
            return [tip.strip() for tip in v.split(',') if tip.strip()]
        if isinstance(v, list):
            return v
        return []

class DestinationBase(BaseModel):
    place_name: str = Field(..., min_length=1, max_length=255)
    location: str = Field(..., min_length=1, max_length=255)
    description: str = Field(..., min_length=1)
    extra_info: Optional[DestinationExtraInfo] = None

class DestinationCreate(DestinationBase):
    pass

class DestinationUpdate(BaseModel):
    place_name: Optional[str] = Field(None, min_length=1, max_length=255)
    location: Optional[str] = None
    description: Optional[str] = None
    extra_info: Optional[DestinationExtraInfo] = None

class DestinationResponse(BaseModel):
    destination_id: int
    place_name: str
    location: str
    description: str
    extra_info: Optional[DestinationExtraInfo] = None

    class Config:
        from_attributes = True

#for genre
class GenreResponse(BaseModel):
    genre_id: int
    name: str
    
    class Config:
        from_attributes = True

class Genre(BaseModel):
    genre_id: int
    name: str


class PreferenceItem(BaseModel):
    genre_ids: List[int]


class PreferenceRequest(BaseModel):
    preferences: PreferenceItem


class PreferenceResponse(BaseModel):
    id: int
    name: str


class UserPreferencesResponse(BaseModel):
    preferences: List[PreferenceResponse]


#for event
class TravelEventBase(BaseModel):
    destination_id: int
    title: str = Field(..., min_length=1, max_length=255)
    event_description: Optional[str] = None
    from_date: datetime
    to_date: datetime
    meeting_time: time
    meeting_point: Optional[str] = None
    what_to_bring: Optional[List[str]] = None
    max_people: int = Field(..., gt=0)
    price: Optional[int] = Field(None, ge=0)

class TravelEventCreate(TravelEventBase):
    pass

class TravelEventUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=1, max_length=255)
    event_description: Optional[str] = None
    from_date: Optional[datetime] = None
    to_date: Optional[datetime] = None
    meeting_time: Optional[time] = None
    meeting_point: Optional[str] = None
    what_to_bring: Optional[List[str]] = None
    max_people: Optional[int] = Field(None, gt=0)
    price: Optional[int] = Field(None, ge=0)

class TravelEventResponse(BaseModel):
    event_id: int
    company_user_id: int
    title: str
    event_description: Optional[str] = None
    from_date: datetime
    to_date: datetime
    meeting_time: Optional[time] = None
    meeting_point: Optional[str] = None
    what_to_bring: Optional[List[str]] = None
    max_people: int
    price: Optional[int] = None
    created_at: datetime
    destination: DestinationResponse

    class Config:
        from_attributes = True


# For Booking
class BookingBase(BaseModel):
    event_id: int
    total_people: int = Field(..., gt=0)

class BookingCreate(BookingBase):
    pass


class BookingResponse(BaseModel):
    booking_id: int
    user_id: int
    transaction_uuid: str
    event_id: int
    total_price: float
    total_people: int
    status: str
    booked_at: datetime

    class Config:
        from_attributes = True


class EsewaInitResponse(BaseModel):
    payment_url: str
    form_data: dict
    booking_id: int
    transaction_uuid: str

# For Referal
class ReferralBase(BaseModel):
    referred_to: int
    booking_id: int


class ReferralCreate(ReferralBase):
    pass


class ReferralResponse(BaseModel):
    referral_id: int
    referred_by: int
    referred_to: int
    booking_id: int

    class Config:
        from_attributes = True


# For Friend Request
class FriendRequestCreate(BaseModel):
    receiver_id: int = Field(..., gt=0)


class FriendRequestAction(BaseModel):
    action: Literal["accept", "reject"]


class FriendRequestResponse(BaseModel):
    id: int
    sender_id: int
    receiver_id: int
    status: str
    created_at: datetime
    responded_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# For Friend

class FriendResponse(BaseModel):
    id: int
    user_id: int
    friend_user_id: int

    class Config:
        from_attributes = True

class RemoveFriendRequest(BaseModel):
    friend_user_id: int = Field(..., gt=0)   

# For Bookmark
class BookmarkCreate(BaseModel):
    destination_id: int


class BookmarkResponse(BaseModel):
    id: int
    user_id: int
    destination_id: int
    created_at: datetime

    class Config:
        from_attributes = True