from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime

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
