from sqlalchemy.orm import Session
from app.model.models import UserGenre, Genre
from typing import List, Tuple

def get_genre_vector(db: Session, genre_ids: List[int]) -> List[int]:
    all_genres = db.query(Genre).order_by(Genre.genre_id).all() #gets all genre available
    vector = []
    for genre in all_genres:
        vector.append(1 if genre.genre_id in genre_ids else 0)
    
    return vector


def update_user_preferences(db: Session, user_id: int, selected_genre_ids: List[int]):
    all_genres = db.query(Genre).all()
    
    for genre in all_genres:
        user_genre = db.query(UserGenre).filter(
            UserGenre.user_id == user_id,
            UserGenre.genre_id == genre.genre_id
        ).first()
        
        # Set value: 1 if in selected_genre_ids, else 0
        new_value = 1 if genre.genre_id in selected_genre_ids else 0
        
        if user_genre:
            user_genre.value = new_value
        else:
            user_genre = UserGenre(
                user_id=user_id,
                genre_id=genre.genre_id,
                value=new_value
            )
            db.add(user_genre)
    
    db.commit()


def get_user_preferences(db: Session, user_id: int):

    results = (
        db.query(Genre.genre_id, Genre.name)
        .join(UserGenre, Genre.genre_id == UserGenre.genre_id)
        .filter(UserGenre.user_id == user_id, UserGenre.value == 1)
        .order_by(Genre.genre_id)
        .all()
    )
    
    return [
        {"id": genre_id, "name": genre_name}
        for genre_id, genre_name in results
    ]

