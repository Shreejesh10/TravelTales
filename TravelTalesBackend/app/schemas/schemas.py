from pydantic import BaseModel, EmailStr, Field, field_validator
from datetime import datetime
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

class UserResponse(BaseModel):
    id: int
    email: EmailStr
    user_name: Optional[str] = None
    created_at: datetime
    roles: str
    status: UserStatus
    class Config:
        
        from_attributes = True  

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

# # Admin approval schema
# class CompanyApprovalRequest(BaseModel):
#     approve: bool 
    
#     rejection_reason: Optional[str] = None

# # Response after admin approval
# class CompanyApprovalResponse(BaseModel):
#     user_id: int
#     company_id: Optional[int] = None
#     status: UserStatus
#     message: str 

#Destination
class DestinationExtraInfo(BaseModel):
    highlights: Optional[List[str]] = []
    attractions: Optional[List[str]] = []
    best_time_to_visit: Optional[str] = None
    transportation: Optional[str] = None
    accommodation: Optional[str] = None
    safety_tips: Optional[List[str]] = []
    photos: Optional[List[str]] = []
    genre_vector: Optional[List[int]] = []

    @field_validator('safety_tips', mode='before')
    @classmethod
    def convert_safety_tips_to_list(cls, v):
        """Convert string safety_tips to list if needed"""
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