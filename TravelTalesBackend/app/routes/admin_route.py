from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.auth.auth import get_admin_user
from app.model.models import User
from app.utils.db_utils import get_db
from app.schemas.schemas import CompanyApprovalResponse, PendingCompanyResponse, RejectRequest
from app.services.services import approve_company, list_pending_companies, reject_company

_SHOW_NAME = "admin"
router = APIRouter(
    prefix=f'/{_SHOW_NAME}',
    tags=[_SHOW_NAME],
    responses={404: {'description': 'Not found'}}
)


@router.get("/companies/pending", response_model=List[PendingCompanyResponse])
def get_pending_companies(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_admin_user),
):
    return list_pending_companies(db)


@router.post("/companies/{user_id}/approve", response_model=CompanyApprovalResponse)
def approve_request(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_admin_user),
):
    try:
        return approve_company(db, user_id)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.post("/companies/{user_id}/reject", response_model=CompanyApprovalResponse)
def reject_request(
    user_id: int,
    body: RejectRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_admin_user),
):
    try:
        return reject_company(db, user_id, body.reason)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
