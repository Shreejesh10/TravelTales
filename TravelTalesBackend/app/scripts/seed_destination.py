import json
import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent.parent))

from sqlalchemy.orm import Session
from app.utils.db_utils import get_db
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
                    raise ValueError(
                        "JSON must contain 'places', 'destinations', or 'data'"
                    )

            else:
                raise ValueError("Invalid JSON structure")

    except FileNotFoundError:
        raise FileNotFoundError(f"Could not find '{json_file_path}'")

    except json.JSONDecodeError as e:
        raise ValueError(f"Invalid JSON format: {str(e)}")


def seed_destinations(db: Session, destinations_data: list):
    added_count = 0
    updated_count = 0
    error_count = 0

    for idx, dest_data in enumerate(destinations_data, 1):
        try:
            if not isinstance(dest_data, dict):
                error_count += 1
                continue

            place_name = dest_data.get("place_name")
            location = dest_data.get("location")
            description = dest_data.get("description")

            if not all([place_name, location, description]):
                error_count += 1
                continue

            extra_info = {
                "highlights": dest_data.get("highlights", []),
                "attractions": dest_data.get("attractions", []),
                "best_time_to_visit": dest_data.get("best_time_to_visit"),
                "transportation": dest_data.get("transportation"),
                "accommodation": dest_data.get("accommodation"),
                "safety_tips": dest_data.get("safety_tips", []),
                "photos": dest_data.get("photos", []),
                "genre_vector": dest_data.get("genre_vector", []),
                "difficulty_level": dest_data.get("difficulty_level"),
                "duration": dest_data.get("duration"),
                "elevation": dest_data.get("elevation", []),
                "backdrop_path": dest_data.get("backdrop_path", []),
                "front_image_path": dest_data.get("front_image_path", [])
            }

            existing = db.query(Destination).filter(
                Destination.place_name == place_name
            ).first()

            if existing:
                existing.location = location
                existing.description = description
                existing.extra_info = extra_info
                updated_count += 1
            else:
                destination = Destination(
                    place_name=place_name,
                    location=location,
                    description=description,
                    extra_info=extra_info
                )
                db.add(destination)
                added_count += 1

        except Exception as e:
            error_count += 1
            print(f"Error processing item {idx}: {e}")
            continue

    try:
        db.commit()
        print(
            f"Seeding completed\n"
            f"Added: {added_count}\n"
            f"Updated: {updated_count}\n"
            f"Errors: {error_count}\n"
            f"Total: {len(destinations_data)}"
        )
    except Exception as e:
        db.rollback()
        raise RuntimeError(f"Database commit failed: {str(e)}")

def main():

    db_gen = get_db()
    db = next(db_gen)

    try:

        json_path = Path(__file__).parent.parent / "destinations.json"

        if not json_path.exists():
            print("Error: destinations.json not found")
            return

        destinations_data = load_destinations_from_json(str(json_path))

        seed_destinations(db, destinations_data)

    except Exception as e:

        db.rollback()
        print(f"Fatal error: {str(e)}")

    finally:

        db.close()


if __name__ == "__main__":
    main()