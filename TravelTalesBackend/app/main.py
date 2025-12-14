from fastapi import FastAPI
from app.routes import user_route
from fastapi.middleware.cors import CORSMiddleware


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

app.include_router(user_route.router)


@app.get("/")
async def main():
    """ this is the entry point of the application. """
    return {"Message" : "Application successfully loaded."}