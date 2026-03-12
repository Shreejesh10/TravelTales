from typing import List
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from sqlalchemy.orm import Session

from app.model.models import Genre, UserGenre, Destination



def get_user_genre_vector(db: Session, user_id: int) -> List[int]:
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

        if user_pref and user_pref.value == 1:
            vector.append(1)
        else:
            vector.append(0)

    return vector

def recommend_destinations(db: Session, user_id: int, top_k: int = 15):
    user_vector = get_user_genre_vector(db, user_id)

    if not user_vector:
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

        popularity_score = extra.get("popularity_score", 0) or 0
        rating_score = extra.get("rating_score", 0) or 0

        final_score = (
            0.75 * similarity +
            0.15 * normalize_score(popularity_score, max_value=100) +
            0.10 * normalize_score(rating_score, max_value=5)
        )

        scored_destinations.append((dest, final_score, similarity))

    if not scored_destinations:
        return []

    # Sort by final score
    scored_destinations.sort(key=lambda x: x[1], reverse=True)

    selected = []
    selected_vectors = []

    for dest, final_score, similarity in scored_destinations:
        dest_vector = np.array(dest.extra_info.get("genre_vector"), dtype=float)

        too_similar = False
        for existing_vector in selected_vectors:
            pair_sim = cosine_similarity(
                dest_vector.reshape(1, -1),
                existing_vector.reshape(1, -1)
            )[0][0]

            if pair_sim > 0.95:
                too_similar = True
                break

        if not too_similar:
            selected.append(dest)
            selected_vectors.append(dest_vector)

        if len(selected) == top_k:
            break

    return selected

def normalize_score(value, max_value):
    if max_value <= 0:
        return 0.0
    return min(max(float(value) / max_value, 0.0), 1.0)