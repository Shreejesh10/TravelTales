from pydantic import BaseModel, EmailStr, Field, field_validator
from typing import Optional
from datetime import datetime
from typing import Optional, List, Dict, Any

class UserCreate(BaseModel):
    email: EmailStr
    password: str 
    user_name: Optional[str] = None
    
    

class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserResponse(BaseModel):
    id: int
    email: EmailStr
    user_name: Optional[str] = None
    created_at: datetime

    class Config:
        
        from_attributes = True  

#Destination
class DestinationExtraInfo(BaseModel):
    highlights: Optional[List[str]] = []
    attractions: Optional[List[str]] = []
    best_time_to_visit: Optional[str] = None
    transportation: Optional[str] = None
    accommodation: Optional[str] = None
    safety_tips: Optional[List[str]] = []
    photos: Optional[List[str]] = []

    @field_validator('safety_tips', mode='before')
    @classmethod
    def convert_safety_tips_to_list(cls, v):
        """Convert string safety_tips to list if needed"""
        if v is None:
            return []
        if isinstance(v, str):
            # Split by comma and strip whitespace
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

