from app.utils.db_utils import Base
from sqlalchemy import Column, Integer,Text,String, DateTime, func
from sqlalchemy.dialects.postgresql import JSONB

class User(Base):
    __tablename__ = "user"

    id = Column(Integer, primary_key= True, index = True)
    
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable= False)
    user_name = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable= False)

class Destination(Base):
    __tablename__ = "destination"
    
    destination_id = Column(Integer, primary_key=True, index=True)
    place_name = Column(String(255), nullable=False, index=True)
    location = Column(String(255), nullable=False)
    description = Column(Text, nullable=False)
    extra_info = Column(JSONB, nullable=True)