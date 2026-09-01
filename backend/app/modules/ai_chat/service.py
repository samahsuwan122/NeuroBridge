from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models import AIChatMessage, AIChatSession, User
from app.modules.ai_chat.provider import provider

# Match portal routing precedence for users who hold more than one role.
SUPPORTED_ROLES = ("doctor", "therapist", "family", "patient")


def companion_role(roles: list[str]) -> str | None:
    for role in SUPPORTED_ROLES:
        if role in roles:
            return role
    return None


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
