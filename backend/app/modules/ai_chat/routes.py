import uuid
from typing import Literal

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models import AIChatSession, User
from app.modules.ai_chat import service
from app.modules.ai_chat.schemas import (
    AIChatHistoryResponse,
    AIChatMessageCreate,
    AIChatMessageRead,
    AIConversationCreate,
    AIConversationListResponse,
    AIConversationMessageCreate,
    AIConversationMessagesResponse,
    AIConversationRename,
    AIConversationRead,
)
from app.modules.auth.dependencies import get_current_active_user
from app.modules.auth.service import get_role_names

router = APIRouter(prefix="/api/v1/ai-chat", tags=["ai-chat"])


def _role(db: Session, user: User) -> str:
    role = service.companion_role(get_role_names(db, user.id))
    if role is None:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="AI Companion is available to patients, families, doctors, and therapists.")
    return role


def _accessible_conversation(
    db: Session, user: User, conversation_id: uuid.UUID
) -> AIChatSession:
    roles = get_role_names(db, user.id)
    conversation = service.get_accessible_conversation(
        db, user, roles, conversation_id
    )
    if conversation is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="AI conversation not found.",
        )
    return conversation


@router.get("/conversations", response_model=AIConversationListResponse)
def list_conversations(
    state: Literal["active", "archived"] = Query(default="active"),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> AIConversationListResponse:
    _role(db, current_user)
    conversations, total = service.list_conversations(
        db,
        current_user,
        get_role_names(db, current_user.id),
        archived=state == "archived",
        limit=limit,
        offset=offset,
    )
    return AIConversationListResponse(
        total=total,
        limit=limit,
        offset=offset,
        conversations=[AIConversationRead.model_validate(item) for item in conversations],
    )


@router.post(
    "/conversations",
    response_model=AIConversationRead,
    status_code=status.HTTP_201_CREATED,
)
def create_conversation(
    payload: AIConversationCreate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> AIConversationRead:
    _role(db, current_user)
    try:
        conversation = service.create_conversation(
            db,
            current_user,
            get_role_names(db, current_user.id),
            role=payload.role,
            patient_profile_id=payload.patient_profile_id,
            title=payload.title,
        )
    except service.ConversationNotAllowedError:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="This AI conversation role or patient context is not available.",
        )
    return AIConversationRead.model_validate(conversation)


@router.patch(
    "/conversations/{conversation_id}", response_model=AIConversationRead
)
def rename_conversation(
    conversation_id: uuid.UUID,
    payload: AIConversationRename,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> AIConversationRead:
    conversation = _accessible_conversation(db, current_user, conversation_id)
    return AIConversationRead.model_validate(
        service.rename_conversation(db, conversation, payload.title)
    )


@router.post(
    "/conversations/{conversation_id}/archive", response_model=AIConversationRead
)
def archive_conversation(
    conversation_id: uuid.UUID,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> AIConversationRead:
    conversation = _accessible_conversation(db, current_user, conversation_id)
    return AIConversationRead.model_validate(
        service.archive_conversation(db, conversation)
    )


@router.post(
    "/conversations/{conversation_id}/restore", response_model=AIConversationRead
)
def restore_conversation(
    conversation_id: uuid.UUID,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> AIConversationRead:
    conversation = _accessible_conversation(db, current_user, conversation_id)
    return AIConversationRead.model_validate(
        service.restore_conversation(db, conversation)
    )


@router.delete(
    "/conversations/{conversation_id}", status_code=status.HTTP_204_NO_CONTENT
)
def delete_conversation(
    conversation_id: uuid.UUID,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> None:
    conversation = _accessible_conversation(db, current_user, conversation_id)
    service.soft_delete_conversation(db, conversation)


@router.get(
    "/conversations/{conversation_id}/messages",
    response_model=AIConversationMessagesResponse,
)
def get_conversation_messages(
    conversation_id: uuid.UUID,
    limit: int = Query(default=100, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> AIConversationMessagesResponse:
    conversation = _accessible_conversation(db, current_user, conversation_id)
    messages, total = service.conversation_messages(
        db, conversation, limit=limit, offset=offset
    )
    return AIConversationMessagesResponse(
        total=total,
        limit=limit,
        offset=offset,
        messages=[AIChatMessageRead.model_validate(item) for item in messages],
    )


@router.post(
    "/conversations/{conversation_id}/messages",
    response_model=AIChatMessageRead,
    status_code=status.HTTP_201_CREATED,
)
def post_conversation_message(
    conversation_id: uuid.UUID,
    payload: AIConversationMessageCreate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> AIChatMessageRead:
    conversation = _accessible_conversation(db, current_user, conversation_id)
    try:
        item = service.send_conversation_message(
            db, current_user, conversation, payload.message
        )
    except service.ArchivedConversationError:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Archived AI conversations are read-only.",
        )
    return AIChatMessageRead.model_validate(item)


@router.post("/message", response_model=AIChatMessageRead, status_code=status.HTTP_201_CREATED)
def post_message(payload: AIChatMessageCreate, current_user: User = Depends(get_current_active_user), db: Session = Depends(get_db)) -> AIChatMessageRead:
    return AIChatMessageRead.model_validate(service.send_message(db, current_user, _role(db, current_user), payload.message))


@router.get("/history", response_model=AIChatHistoryResponse)
def get_history(limit: int = Query(default=100, ge=1, le=200), current_user: User = Depends(get_current_active_user), db: Session = Depends(get_db)) -> AIChatHistoryResponse:
    _role(db, current_user)
    return AIChatHistoryResponse(messages=[AIChatMessageRead.model_validate(item) for item in service.history(db, current_user, limit)])
