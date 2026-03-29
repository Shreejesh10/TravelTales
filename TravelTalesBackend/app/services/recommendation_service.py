from typing import List
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from sqlalchemy.orm import Session

from app.model.models import Genre, UserGenre, Destination



from typing import List
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from sqlalchemy.orm import Session

from app.model.models import Genre, UserGenre, Destination


def get_user_genre_vector(db: Session, user_id: int) -> List[float]:
    all_genres = db.query(Genre).order_by(Genre.genre_id).all()
    vector = []

    for genre in all_genres:
        user_pref = (
            db.query(UserGenre)
            .filter(
                UserGenre.user_id == user_id,
                UserGenre.genre_id == genre.genre_id
            )
            .first()
        )

        if user_pref:
            vector.append(float(user_pref.value))
        else:
            vector.append(0.0)

    return vector

def recommend_destinations(db: Session, user_id: int, top_k: int = 15):
    user_vector = get_user_genre_vector(db, user_id)

    if not user_vector or sum(user_vector) == 0:
        return []

    user_array = np.array(user_vector, dtype=float).reshape(1, -1)

    destinations = db.query(Destination).all()
    scored_destinations = []

    for dest in destinations:
        extra = dest.extra_info or {}
        dest_vector = extra.get("genre_vector")

        if not dest_vector:
            continue

        if len(dest_vector) != len(user_vector):
            continue

        dest_array = np.array(dest_vector, dtype=float).reshape(1, -1)

        similarity = cosine_similarity(user_array, dest_array)[0][0]

        popularity_score = normalize_score(extra.get("popularity_score", 0), 100)
        rating_score = normalize_score(extra.get("rating_score", 0), 5)

        final_score = (
            0.80 * similarity +
            0.12 * popularity_score +
            0.08 * rating_score
        )

        scored_destinations.append((dest, final_score))

    scored_destinations.sort(key=lambda x: x[1], reverse=True)

    return [dest for dest, _ in scored_destinations[:top_k]]

def normalize_score(value, max_value):
    if max_value <= 0:
        return 0.0
    return min(max(float(value) / max_value, 0.0), 1.0)

def update_user_genre_vector_from_destination(
    db: Session,
    user_id: int,
    destination_id: int,
    alpha: float = 0.5
):
    destination = (
        db.query(Destination)
        .filter(Destination.destination_id == destination_id)
        .first()
    )

    if not destination:
        return

    dest_vector = (destination.extra_info or {}).get("genre_vector", [])
    if not dest_vector:
        return

    all_genres = db.query(Genre).order_by(Genre.genre_id).all()

    if len(dest_vector) != len(all_genres):
        return

    for i, genre in enumerate(all_genres):
        clicked_value = float(dest_vector[i])

        user_pref = (
            db.query(UserGenre)
            .filter(
                UserGenre.user_id == user_id,
                UserGenre.genre_id == genre.genre_id
            )
            .first()
        )

        if user_pref:
            current_value = float(user_pref.value)
            new_value = min(1.0, current_value + alpha * clicked_value)
            user_pref.value = round(new_value, 2)
        else:
            new_value = round(alpha * clicked_value, 2)

            new_pref = UserGenre(
                user_id=user_id,
                genre_id=genre.genre_id,
                value=new_value
            )
            db.add(new_pref)

    db.commit()