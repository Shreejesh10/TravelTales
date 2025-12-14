from app.utils.db_utils import Base
from sqlalchemy import Column, Integer, String, DateTime, func

class User(Base):
    __tablename__ = "user"

    id = Column(Integer, primary_key= True, index = True)
    
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable= False)
    user_name = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable= False)
    