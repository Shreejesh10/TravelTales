import json
import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent.parent))

from sqlalchemy.orm import Session
from app.utils.db_utils import SessionLocal, engine, Base, get_db
from app.model.models import Destination

def load_destinations_from_json(json_file_path: str):
    try:
        with open(json_file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
            if isinstance(data, list):
                return data
            elif isinstance(data, dict):
                if 'places' in data:
                    return data['places']
                elif 'destinations' in data:
                    return data['destinations']
                elif 'data' in data:
                    return data['data']
                else:
                    raise ValueError("JSON object must contain 'places', 'destinations', or 'data' key")
            else:
                raise ValueError("JSON must be an array or an object with destinations")
    except FileNotFoundError:
        raise FileNotFoundError(f"Could not find file '{json_file_path}'")
    except json.JSONDecodeError as e:
        raise ValueError(f"Invalid JSON format: {str(e)}")

def seed_destinations(db: Session, destinations_data: list):
    added_count = 0
    skipped_count = 0
    error_count = 0
    
    for idx, dest_data in enumerate(destinations_data, 1):
        try:
            if not isinstance(dest_data, dict):
                error_count += 1
                continue
            
            place_name = dest_data.get('place_name')
            location = dest_data.get('location')
            description = dest_data.get('description')
            
            if not all([place_name, location, description]):
                error_count += 1
                continue
            
            extra_info = {
                'highlights': dest_data.get('highlights', []),
                'attractions': dest_data.get('attractions', []),
                'best_time_to_visit': dest_data.get('best_time_to_visit'),
                'transportation': dest_data.get('transportation'),
                'accommodation': dest_data.get('accommodation'),
                'safety_tips': dest_data.get('safety_tips', []),
                'photos': dest_data.get('photos', [])
            }
            
            existing = db.query(Destination).filter(
                Destination.place_name == place_name
            ).first()
            
            if existing:
                skipped_count += 1
                continue
            
            destination = Destination(
                place_name=place_name,
                location=location,
                description=description,
                extra_info=extra_info
            )
            
            db.add(destination)
            added_count += 1
            
        except Exception:
            error_count += 1
            continue
    
    try:
        db.commit()
        print(f"Seeding completed: Added={added_count}, Skipped={skipped_count}, Errors={error_count}, Total={len(destinations_data)}")
    except Exception as e:
        db.rollback()
        raise RuntimeError(f"Error committing to database: {str(e)}")

def main():
    db_gen = get_db()
    db = next(db_gen)
    
    try:
        possible_paths = [
            "app/destinations.json",
            Path(__file__).parent.parent.parent / "destinations.json"
        ]
        
        json_file = None
        for path in possible_paths:
            if Path(path).exists():
                json_file = str(path)
                break
        
        if not json_file:
            print("Error: Could not find 'destinations.json' in expected locations")
            return
        
        destinations_data = load_destinations_from_json(json_file)
        seed_destinations(db, destinations_data)
        
    except Exception as e:
        db.rollback()
        print(f"Fatal error: {str(e)}")
    finally:
        db.close()

if __name__ == "__main__":
    main()
