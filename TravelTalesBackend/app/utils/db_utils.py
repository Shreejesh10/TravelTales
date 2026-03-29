import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from dotenv import load_dotenv
from sqlalchemy.orm import configure_mappers
from sqlalchemy import inspect

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    raise ValueError("Database URL is missing")

engine = create_engine(DATABASE_URL)

SessionLocal = sessionmaker(autocommit = False, autoflush=False, bind = engine)

Base = declarative_base()

def get_db():
    db = SessionLocal()
    try: 
        yield db
    finally:
        db.close()

def create_table():
    
    Base.metadata.create_all(bind=engine)

def ensure_create_all():
    configure_mappers()

    inspector = inspect(engine)
    

    Base.metadata.create_all(bind=engine)

    inspector = inspect(engine)
   


