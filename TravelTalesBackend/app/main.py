from fastapi import FastAPI
from app.routes import  bookmark_route, destination_route, friend_route, user_route, genre_route, admin_route, event_route, booking_route
from app.utils.db_utils import ensure_create_all
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pathlib import Path
from app.utils.db_utils import Base
from app.services.scheduler_service import start_scheduler, stop_scheduler

app = FastAPI()

from .env_loader import load_env

load_env()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

BASE_DIR = Path(__file__).resolve().parent   # TravelTalesBackend/app
MEDIA_DIR = BASE_DIR.parent / "media"        # TravelTalesBackend/media

(MEDIA_DIR / "profile_photos").mkdir(parents=True, exist_ok=True)
app.mount("/media", StaticFiles(directory=str(MEDIA_DIR)), name="media")

# print("Serving MEDIA from:", MEDIA_DIR)

# # Run this after creating a new table in models
# print("Ensuring all the tables are created")
# ensure_create_all()

app.include_router(user_route.router)
app.include_router(destination_route.router)
app.include_router(genre_route.router)
app.include_router(admin_route.router)
app.include_router(event_route.router)
app.include_router(booking_route.router)
app.include_router(friend_route.router)
app.include_router(bookmark_route.router)


@app.on_event("startup")
def on_startup():
    start_scheduler()


@app.on_event("shutdown")
def on_shutdown():
    stop_scheduler()


@app.get("/")
async def main():
    return {"Message" : "Application successfully loaded."}
