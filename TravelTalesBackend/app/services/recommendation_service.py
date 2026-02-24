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



def recommend_destinations(db: Session, user_id: int, top_k: int = 5):

    user_vector = get_user_genre_vector(db, user_id)


    user_array = np.array(user_vector).reshape(1, -1)

    destinations = db.query(Destination).all()

    destination_objects = []
    destination_vectors = []

    for dest in destinations:
        extra = dest.extra_info or {}
        dest_vector = extra.get("genre_vector")

        if dest_vector and len(dest_vector) == len(user_vector):
            destination_objects.append(dest)
            destination_vectors.append(dest_vector)

    if not destination_vectors:
        return []

    destination_array = np.array(destination_vectors)

    similarities = cosine_similarity(user_array, destination_array)

    similarity_scores = similarities[0]

    scored = list(zip(destination_objects, similarity_scores))

    scored.sort(key=lambda x: x[1], reverse=True)

    return [item[0] for item in scored[:top_k]]