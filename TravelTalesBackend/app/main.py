from fastapi import FastAPI
from app.routes import  destination_route, user_route, genre_route, admin_route
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import os
from pathlib import Path

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

print("Serving MEDIA from:", MEDIA_DIR)

app.include_router(user_route.router)
app.include_router(destination_route.router)
app.include_router(genre_route.router)
app.include_router(admin_route.router)


@app.get("/")
async def main():
    return {"Message" : "Application successfully loaded."}