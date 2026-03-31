from datetime import datetime
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import or_

from app.model.models import User, Friend, FriendRequest


def send_friend_request(db: Session, current_user: User, receiver_id: int) -> FriendRequest:
    if current_user.id == receiver_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You cannot send a friend request to yourself."
        )

    receiver = db.query(User).filter(User.id == receiver_id).first()
    if not receiver:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Receiver user not found."
        )

    # Check if already friends
    user_id = min(current_user.id, receiver_id)
    friend_user_id = max(current_user.id, receiver_id)

    existing_friend = db.query(Friend).filter(
        Friend.user_id == user_id,
        Friend.friend_user_id == friend_user_id
    ).first()

    if existing_friend:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You are already friends with this user."
        )

    # Check if same pending request already exists
    existing_request = db.query(FriendRequest).filter(
        FriendRequest.sender_id == current_user.id,
        FriendRequest.receiver_id == receiver_id,
        FriendRequest.status == "pending"
    ).first()

    if existing_request:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Friend request already sent."
        )

    # Check reverse pending request
    reverse_request = db.query(FriendRequest).filter(
        FriendRequest.sender_id == receiver_id,
        FriendRequest.receiver_id == current_user.id,
        FriendRequest.status == "pending"
    ).first()

    if reverse_request:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This user has already sent you a friend request. Please accept or reject it."
        )

    friend_request = FriendRequest(
        sender_id=current_user.id,
        receiver_id=receiver_id,
        status="pending"
    )

    db.add(friend_request)
    db.commit()
    db.refresh(friend_request)

    return friend_request


def accept_friend_request(db: Session, current_user: User, request_id: int) -> FriendRequest:
    friend_request = db.query(FriendRequest).filter(
        FriendRequest.id == request_id
    ).first()

    if not friend_request:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Friend request not found."
        )

    if friend_request.receiver_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You are not allowed to accept this friend request."
        )

    if friend_request.status != "pending":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Cannot accept a {friend_request.status} request."
        )

    user_id = min(friend_request.sender_id, friend_request.receiver_id)
    friend_user_id = max(friend_request.sender_id, friend_request.receiver_id)

    existing_friend = db.query(Friend).filter(
        Friend.user_id == user_id,
        Friend.friend_user_id == friend_user_id
    ).first()

    if existing_friend:
        friend_request.status = "accepted"
        friend_request.responded_at = datetime.utcnow()
        db.commit()
        db.refresh(friend_request)
        return friend_request

    new_friendship = Friend(
        user_id=user_id,
        friend_user_id=friend_user_id
    )

    friend_request.status = "accepted"
    friend_request.responded_at = datetime.utcnow()

    db.add(new_friendship)
    db.commit()
    db.refresh(friend_request)

    return friend_request


def reject_friend_request(db: Session, current_user: User, request_id: int) -> FriendRequest:
    friend_request = db.query(FriendRequest).filter(
        FriendRequest.id == request_id
    ).first()

    if not friend_request:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Friend request not found."
        )

    if friend_request.receiver_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You are not allowed to reject this friend request."
        )

    if friend_request.status != "pending":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Cannot reject a {friend_request.status} request."
        )

    friend_request.status = "rejected"
    friend_request.responded_at = datetime.utcnow()

    db.commit()
    db.refresh(friend_request)

    return friend_request


def remove_friend(db: Session, current_user: User, friend_user_id: int) -> dict:
    if current_user.id == friend_user_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You cannot remove yourself."
        )

    user_id = min(current_user.id, friend_user_id)
    other_user_id = max(current_user.id, friend_user_id)

    friendship = db.query(Friend).filter(
        Friend.user_id == user_id,
        Friend.friend_user_id == other_user_id
    ).first()

    if not friendship:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Friendship not found."
        )

    db.delete(friendship)
    db.commit()

    return {"message": "Friend removed successfully."}


def get_incoming_friend_requests(db: Session, current_user: User):
    return db.query(FriendRequest).filter(
        FriendRequest.receiver_id == current_user.id
    ).order_by(FriendRequest.created_at.desc()).all()


def get_outgoing_friend_requests(db: Session, current_user: User):
    return db.query(FriendRequest).filter(
        FriendRequest.sender_id == current_user.id
    ).order_by(FriendRequest.created_at.desc()).all()


def get_my_friends(db: Session, current_user: User):
    friendships = db.query(Friend).filter(
        or_(
            Friend.user_id == current_user.id,
            Friend.friend_user_id == current_user.id
        )
    ).all()

    return friendships