"""Provider inquiry message + chat routes.

- GET  /api/v1/provider-messages — list threads (with reply preview + unread).
- GET  /api/v1/provider-messages/unread-count — total unread replies for viewer.
- GET  /api/v1/provider-messages/{id} — a full thread (inquiry + replies).
- POST /api/v1/provider-messages — start a new inquiry thread.
- POST /api/v1/provider-messages/{id}/replies — reply in a thread.
- PATCH /api/v1/provider-messages/{id}/read — mark the thread's replies read.

MEDICAL SAFETY: non-urgent care-coordination content only — never emergency
care, medical advice, diagnosis, or assessment.
"""

import uuid
from contextlib import contextmanager
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models import (
    PatientProfile,
    ProviderMessage,
    ProviderMessageReply,
    User,
)
from app.modules.auth.dependencies import get_current_active_user
from app.modules.auth.service import get_role_names
from app.modules.messages import service
from app.modules.messages.schemas import (
    MarkReadResponse,
    ProviderMessageCreate,
    ProviderMessageListResponse,
    ProviderMessageResponse,
    ProviderMessageThreadResponse,
    ProviderReplyCreate,
    ProviderReplyResponse,
    UnreadCountResponse,
)

router = APIRouter(prefix="/api/v1/provider-messages", tags=["provider-messages"])


@contextmanager
def _translate_errors():
    try:
        yield
    except service.ProfileNotFoundError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Patient profile not found.",
        )
    except service.ProviderNotFoundError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Selected care provider was not found.",
        )
    except service.NotAllowedError:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You are not allowed to perform this action.",
        )


def _client_info(request: Request) -> tuple[str | None, str | None]:
    ip_address = request.client.host if request.client else None
    device_info = request.headers.get("user-agent")
    return ip_address, device_info


def _name(db: Session, user_id: Optional[uuid.UUID]) -> Optional[str]:
    if user_id is None:
        return None
    user = db.get(User, user_id)
    return user.full_name if user is not None else None


def _reply_response(
    db: Session, reply: ProviderMessageReply
) -> ProviderReplyResponse:
    resp = ProviderReplyResponse.model_validate(reply)
    resp.sender_name = _name(db, reply.sender_user_id)
    return resp


def _fill_thread_fields(
    db: Session,
    msg: ProviderMessage,
    resp: ProviderMessageResponse,
    agg: Optional[dict],
) -> None:
    resp.provider_name = _name(db, msg.provider_user_id)
    resp.sender_name = _name(db, msg.sender_user_id)
    profile = db.get(PatientProfile, msg.patient_profile_id)
    if profile is not None:
        resp.patient_name = _name(db, profile.user_id)
    if agg is not None:
        resp.latest_reply_preview = agg.get("latest_preview")
        resp.latest_reply_at = agg.get("latest_at")
        resp.unread_reply_count = agg.get("unread", 0)


def _msg_response(
    db: Session, msg: ProviderMessage, agg: Optional[dict] = None
) -> ProviderMessageResponse:
    resp = ProviderMessageResponse.model_validate(msg)
    _fill_thread_fields(db, msg, resp, agg)
    return resp


@router.get("", response_model=ProviderMessageListResponse)
def list_provider_messages(
    provider_user_id: Optional[uuid.UUID] = Query(default=None),
    patient_profile_id: Optional[uuid.UUID] = Query(default=None),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> ProviderMessageListResponse:
    roles = get_role_names(db, current_user.id)
    items, total = service.list_provider_messages(
        db,
        current_user,
        roles,
        provider_user_id=provider_user_id,
        patient_profile_id=patient_profile_id,
        limit=limit,
        offset=offset,
    )
    aggregates = service.reply_aggregates(
        db, [i.id for i in items], current_user.id
    )
    return ProviderMessageListResponse(
        total=total,
        limit=limit,
        offset=offset,
        messages=[_msg_response(db, i, aggregates.get(i.id)) for i in items],
    )


@router.get("/unread-count", response_model=UnreadCountResponse)
def provider_messages_unread_count(
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> UnreadCountResponse:
    roles = get_role_names(db, current_user.id)
    return UnreadCountResponse(
        unread_count=service.unread_count(db, current_user, roles)
    )


@router.get("/{message_id}", response_model=ProviderMessageThreadResponse)
def get_provider_message_thread(
    message_id: uuid.UUID,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> ProviderMessageThreadResponse:
    msg = service.get_message(db, message_id)
    if msg is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Thread not found."
        )
    roles = get_role_names(db, current_user.id)
    if not service.can_view_thread(db, current_user, roles, msg):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You are not allowed to view this thread.",
        )
    replies = service.list_replies(db, msg.id)
    agg = service.reply_aggregates(db, [msg.id], current_user.id).get(msg.id)
    resp = ProviderMessageThreadResponse.model_validate(msg)
    _fill_thread_fields(db, msg, resp, agg)
    resp.replies = [_reply_response(db, r) for r in replies]
    return resp


@router.post(
    "",
    response_model=ProviderMessageResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_provider_message(
    payload: ProviderMessageCreate,
    request: Request,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> ProviderMessageResponse:
    roles = get_role_names(db, current_user.id)
    ip_address, device_info = _client_info(request)
    with _translate_errors():
        msg = service.create_provider_message(
            db,
            sender=current_user,
            roles=roles,
            provider_user_id=payload.provider_user_id,
            patient_profile_id=payload.patient_profile_id,
            message=payload.message,
            ip_address=ip_address,
            device_info=device_info,
        )
    return _msg_response(db, msg)


@router.post(
    "/{message_id}/replies",
    response_model=ProviderReplyResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_provider_message_reply(
    message_id: uuid.UUID,
    payload: ProviderReplyCreate,
    request: Request,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> ProviderReplyResponse:
    msg = service.get_message(db, message_id)
    if msg is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Thread not found."
        )
    roles = get_role_names(db, current_user.id)
    ip_address, device_info = _client_info(request)
    with _translate_errors():
        reply = service.create_reply(
            db,
            message=msg,
            sender=current_user,
            roles=roles,
            body=payload.body,
            ip_address=ip_address,
            device_info=device_info,
        )
    return _reply_response(db, reply)


@router.patch("/{message_id}/read", response_model=MarkReadResponse)
def mark_provider_message_read(
    message_id: uuid.UUID,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> MarkReadResponse:
    msg = service.get_message(db, message_id)
    if msg is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Thread not found."
        )
    roles = get_role_names(db, current_user.id)
    if not service.can_view_thread(db, current_user, roles, msg):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You are not allowed to view this thread.",
        )
    marked = service.mark_thread_read(db, message=msg, viewer=current_user)
    return MarkReadResponse(marked_read=marked)
