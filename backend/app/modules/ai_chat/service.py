import uuid
from datetime import timedelta, timezone
from typing import Iterable, Optional

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models import AIChatMessage, AIChatSession, User
from app.db.mixins import utcnow
from app.modules.ai_chat.provider import provider
from app.modules.patients.service import can_view_profile, get_profile

# Match portal routing precedence for users who hold more than one role.
SUPPORTED_ROLES = ("doctor", "therapist", "family", "patient")


def companion_role(roles: list[str]) -> str | None:
    for role in SUPPORTED_ROLES:
        if role in roles:
            return role
    return None


def can_use_patient_context(
    session: Session,
    user: User,
    role: str,
    patient_profile_id: uuid.UUID,
) -> bool:
    """Whether ``user`` may use this patient under the exact AI role.

    Passing only ``role`` to the shared patient visibility helper is
    intentional: a multi-role user cannot use one role's access while opening
    a conversation isolated to another role.
    """
    if role not in SUPPORTED_ROLES:
        return False
    profile = get_profile(session, patient_profile_id)
    if profile is None:
        return False
    return can_view_profile(session, user, {role}, profile)


def can_access_conversation(
    session: Session,
    user: User,
    roles: Iterable[str],
    conversation: AIChatSession,
) -> bool:
    """Owner-, role-, patient-, and deletion-scoped conversation access."""
    role = companion_role(list(roles))
    if role is None:
        return False
    if conversation.deleted_at is not None:
        return False
    if conversation.user_id != user.id or conversation.role != role:
        return False
    if conversation.patient_profile_id is None:
        return True
    return can_use_patient_context(
        session, user, role, conversation.patient_profile_id
    )


def get_accessible_conversation(
    session: Session,
    user: User,
    roles: Iterable[str],
    conversation_id: uuid.UUID,
) -> Optional[AIChatSession]:
    """Return an accessible conversation, otherwise ``None``.

    Future routes should translate ``None`` to the same 404 response whether
    the row is absent, belongs to someone else, has another role, has an
    inaccessible patient context, or is soft-deleted. This avoids enumeration.
    Archived conversations remain accessible.
    """
    conversation = session.get(AIChatSession, conversation_id)
    if conversation is None:
        return None
    if not can_access_conversation(session, user, roles, conversation):
        return None
    return conversation


class ConversationNotAllowedError(Exception):
    """The requested role or patient context is not available to the user."""


class ArchivedConversationError(Exception):
    """Archived conversations are read-only."""


def create_conversation(
    session: Session,
    user: User,
    roles: Iterable[str],
    *,
    role: str,
    patient_profile_id: Optional[uuid.UUID] = None,
    title: Optional[str] = None,
) -> AIChatSession:
    if companion_role(list(roles)) != role:
        raise ConversationNotAllowedError()
    if patient_profile_id is not None and not can_use_patient_context(
        session, user, role, patient_profile_id
    ):
        raise ConversationNotAllowedError()
    conversation = AIChatSession(
        user_id=user.id,
        role=role,
        patient_profile_id=patient_profile_id,
        title=title.strip() if title else None,
    )
    session.add(conversation)
    session.commit()
    session.refresh(conversation)
    return conversation


def list_conversations(
    session: Session,
    user: User,
    roles: Iterable[str],
    *,
    archived: bool,
    limit: int,
    offset: int,
) -> tuple[list[AIChatSession], int]:
    role = companion_role(list(roles))
    if role is None:
        raise ConversationNotAllowedError()
    conditions = [
        AIChatSession.user_id == user.id,
        AIChatSession.role == role,
        AIChatSession.deleted_at.is_(None),
        (
            AIChatSession.archived_at.is_not(None)
            if archived
            else AIChatSession.archived_at.is_(None)
        ),
    ]
    rows = list(
        session.execute(
            select(AIChatSession)
            .where(*conditions)
            .order_by(AIChatSession.updated_at.desc(), AIChatSession.created_at.desc())
        )
        .scalars()
        .all()
    )
    accessible = [
        item for item in rows if can_access_conversation(session, user, roles, item)
    ]
    return accessible[offset : offset + limit], len(accessible)


def conversation_messages(
    session: Session,
    conversation: AIChatSession,
    *,
    limit: int,
    offset: int,
) -> tuple[list[AIChatMessage], int]:
    total = session.execute(
        select(func.count())
        .select_from(AIChatMessage)
        .where(AIChatMessage.session_id == conversation.id)
    ).scalar_one()
    # Offset is measured from the newest exchange, avoiding the legacy endpoint's
    # oldest-first limit bug. Reverse the selected window for chat rendering.
    rows = list(
        session.execute(
            select(AIChatMessage)
            .where(AIChatMessage.session_id == conversation.id)
            .order_by(AIChatMessage.created_at.desc(), AIChatMessage.id.desc())
            .offset(offset)
            .limit(limit)
        )
        .scalars()
        .all()
    )
    rows.reverse()
    return rows, int(total)


def rename_conversation(
    session: Session, conversation: AIChatSession, title: str
) -> AIChatSession:
    conversation.title = title
    conversation.updated_at = utcnow()
    session.add(conversation)
    session.commit()
    session.refresh(conversation)
    return conversation


def archive_conversation(
    session: Session, conversation: AIChatSession
) -> AIChatSession:
    if conversation.archived_at is None:
        now = utcnow()
        conversation.archived_at = now
        conversation.updated_at = now
        session.add(conversation)
        session.commit()
        session.refresh(conversation)
    return conversation


def restore_conversation(
    session: Session, conversation: AIChatSession
) -> AIChatSession:
    if conversation.archived_at is not None:
        conversation.archived_at = None
        conversation.updated_at = utcnow()
        session.add(conversation)
        session.commit()
        session.refresh(conversation)
    return conversation


def soft_delete_conversation(
    session: Session, conversation: AIChatSession
) -> None:
    now = utcnow()
    conversation.deleted_at = now
    conversation.updated_at = now
    session.add(conversation)
    session.commit()


def send_conversation_message(
    session: Session,
    user: User,
    conversation: AIChatSession,
    text: str,
) -> AIChatMessage:
    if conversation.archived_at is not None:
        raise ArchivedConversationError()
    response = provider.respond(
        message=text,
        role=conversation.role,
        language=user.preferred_language,
    )
    created_at = utcnow()
    latest_created_at = session.execute(
        select(func.max(AIChatMessage.created_at)).where(
            AIChatMessage.session_id == conversation.id
        )
    ).scalar_one_or_none()
    if latest_created_at is not None:
        if latest_created_at.tzinfo is None:
            latest_created_at = latest_created_at.replace(tzinfo=timezone.utc)
        if created_at <= latest_created_at:
            created_at = latest_created_at + timedelta(microseconds=1)
    item = AIChatMessage(
        session_id=conversation.id,
        user_id=user.id,
        role=conversation.role,
        message=text,
        assistant_response=response,
        created_at=created_at,
        updated_at=created_at,
    )
    conversation.updated_at = created_at
    session.add_all([conversation, item])
    session.commit()
    session.refresh(item)
    return item


def send_message(session: Session, user: User, role: str, text: str) -> AIChatMessage:
    chat = session.execute(
        select(AIChatSession)
        .where(AIChatSession.user_id == user.id, AIChatSession.role == role)
        .order_by(AIChatSession.created_at.desc())
    ).scalars().first()
    if chat is None:
        chat = AIChatSession(user_id=user.id, role=role)
        session.add(chat)
        session.flush()
    response = provider.respond(message=text, role=role, language=user.preferred_language)
    item = AIChatMessage(
        session_id=chat.id, user_id=user.id, role=role,
        message=text, assistant_response=response,
    )
    session.add(item)
    session.commit()
    session.refresh(item)
    return item


def history(session: Session, user: User, limit: int) -> list[AIChatMessage]:
    return list(session.execute(
        select(AIChatMessage)
        .where(AIChatMessage.user_id == user.id)
        .order_by(AIChatMessage.created_at.asc())
        .limit(limit)
    ).scalars().all())
