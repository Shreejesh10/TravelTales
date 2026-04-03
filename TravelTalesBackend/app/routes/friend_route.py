from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from typing import List

from app.utils.db_utils import get_db
from app.auth.auth import get_current_user
from app.model.models import User
from app.schemas.schemas import (
    FriendRequestCreate,
    FriendRequestResponse,
    FriendResponse,
    RemoveFriendRequest,
)
from app.services.friend_service import (
    send_friend_request,
    accept_friend_request,
    reject_friend_request,
    cancel_friend_request,
    remove_friend,
    get_incoming_friend_requests,
    get_outgoing_friend_requests,
    get_my_friends,
)

router = APIRouter(
    prefix="/friends",
    tags=["Friends"]
)


@router.post(
    "/request",
    response_model=FriendRequestResponse,
    status_code=status.HTTP_201_CREATED
)
def create_friend_request(
    payload: FriendRequestCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return send_friend_request(
        db=db,
        current_user=current_user,
        receiver_id=payload.receiver_id
    )


@router.patch(
    "/request/{request_id}/accept",
    response_model=FriendRequestResponse,
    status_code=status.HTTP_200_OK
)
def accept_request(
    request_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return accept_friend_request(
        db=db,
        current_user=current_user,
        request_id=request_id
    )


@router.patch(
    "/request/{request_id}/reject",
    response_model=FriendRequestResponse,
    status_code=status.HTTP_200_OK
)
def reject_request(
    request_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return reject_friend_request(
        db=db,
        current_user=current_user,
        request_id=request_id
    )


@router.delete(
    "/request/{request_id}",
    response_model=FriendRequestResponse,
    status_code=status.HTTP_200_OK
)
def cancel_request(
    request_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return cancel_friend_request(
        db=db,
        current_user=current_user,
        request_id=request_id
    )


@router.get(
    "/requests/incoming",
    response_model=List[FriendRequestResponse],
    status_code=status.HTTP_200_OK
)
def list_incoming_requests(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return get_incoming_friend_requests(
        db=db,
        current_user=current_user
    )


@router.get(
    "/requests/outgoing",
    response_model=List[FriendRequestResponse],
    status_code=status.HTTP_200_OK
)
def list_outgoing_requests(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return get_outgoing_friend_requests(
        db=db,
        current_user=current_user
    )


@router.get(
    "",
    response_model=List[FriendResponse],
    status_code=status.HTTP_200_OK
)
def list_friends(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return get_my_friends(
        db=db,
        current_user=current_user
    )


@router.delete(
    "",
    status_code=status.HTTP_200_OK
)
def delete_friend(
    payload: RemoveFriendRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return remove_friend(
        db=db,
        current_user=current_user,
        friend_user_id=payload.friend_user_id
    )
