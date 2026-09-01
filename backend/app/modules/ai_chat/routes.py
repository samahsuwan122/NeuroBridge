from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models import User
from app.modules.ai_chat import service
from app.modules.ai_chat.schemas import AIChatHistoryResponse, AIChatMessageCreate, AIChatMessageRead
from app.modules.auth.dependencies import get_current_active_user
from app.modules.auth.service import get_role_names

router = APIRouter(prefix="/api/v1/ai-chat", tags=["ai-chat"])


def _role(db: Session, user: User) -> str:
    role = service.companion_role(get_role_names(db, user.id))
    if role is None:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="AI Companion is available to patients, families, doctors, and therapists.")
    return role


@router.post("/message", response_model=AIChatMessageRead, status_code=status.HTTP_201_CREATED)
def post_message(payload: AIChatMessageCreate, current_user: User = Depends(get_current_active_user), db: Session = Depends(get_db)) -> AIChatMessageRead:
    return AIChatMessageRead.model_validate(service.send_message(db, current_user, _role(db, current_user), payload.message))


@router.get("/history", response_model=AIChatHistoryResponse)
def get_history(limit: int = Query(default=100, ge=1, le=200), current_user: User = Depends(get_current_active_user), db: Session = Depends(get_db)) -> AIChatHistoryResponse:
    _role(db, current_user)
    return AIChatHistoryResponse(messages=[AIChatMessageRead.model_validate(item) for item in service.history(db, current_user, limit)])
