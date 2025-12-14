from dotenv import load_dotenv
from pathlib import Path

# THis is for finding the parents root where .env file is located
def load_env():
    current_dir = Path(__file__).resolve()
    for parent in current_dir.parents:
        env_path = parent.parent /".env"
        if env_path.exists():
            load_dotenv(env_path)
            return
        raise FileNotFoundError(".env file not found in any parent directories")