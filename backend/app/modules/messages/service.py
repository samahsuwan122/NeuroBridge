"""Provider inquiry messaging + chat business logic and access control.

HTTP-free: routes translate the domain exceptions below into HTTP responses.
Access reuses the patient-profile visibility rules so RBAC lives in one place.

A ProviderMessage is a thread (the first inquiry). ProviderMessageReply rows are
the follow-up chat messages. Read tracking on replies drives the in-app unread
badge (a reply is unread for a user when they did not send it and it has no
read_at).

MEDICAL SAFETY: non-urgent care-coordination content only. Messages are never
analyzed, scored, or used to infer any medical condition.

Access model:
- Create thread: a linked family member or an admin only, addressed to an
  existing care provider (doctor/therapist) about a patient they may view.
- View thread: admin=all; a doctor/therapist sees threads addressed to them
  (provider) OR about a patient they can see; the family sender sees their own
  threads; family/patient see threads about a patient they can view.
- Reply: the addressed provider, the family sender, or an admin.
"""

import uuid
from datetime import datetime, timezone
from typing import Dict, Iterable, List, Optional, Tuple

from sqlalchemy import func, or_, select, update
from sqlalchemy.orm import Session

from app.core.permissions import CLINICAL_ROLES, ROLE_ADMIN, ROLE_FAMILY
from app.models import (
    PatientProfile,
    ProviderMessage,
    ProviderMessageReply,
    User,
)
from app.modules.audit.service import record_audit
from app.modules.patients.service import (
    can_view_profile,
    visible_patient_profile_ids,
)
from app.modules.providers.service import provider_roles

STATUS_SENT = "sent"
STATUS_ANSWERED = "answered"

# How much of the latest reply to surface in the thread list preview.
_PREVIEW_CHARS = 140


# --- domain exceptions -------------------------------------------------------


class MessageError(Exception):
    """Base class for provider-message domain errors."""


class ProfileNotFoundError(MessageError):
    """The referenced patient profile does not exist."""


class ProviderNotFoundError(MessageError):
    """The referenced provider does not exist or is not a care provider."""


class NotAllowedError(MessageError):
    """The user is not allowed to perform this action."""


# Only a linked family member or an admin may send an inquiry.
_CREATE_ROLES = frozenset({ROLE_FAMILY, ROLE_ADMIN})


# --- access helpers ----------------------------------------------------------


def get_message(
    session: Session, message_id: uuid.UUID
) -> Optional[ProviderMessage]:
    msg = session.get(ProviderMessage, message_id)
    if msg is None or msg.deleted_at is not None:
        return None
    return msg


def can_view_thread(
    session: Session,
    viewer: User,
    roles: Iterable[str],
    message: ProviderMessage,
) -> bool:
    visible = visible_patient_profile_ids(session, viewer, roles)
    if visible is None:  # admin
        return True
    return (
        message.patient_profile_id in visible
        or message.provider_user_id == viewer.id
        or message.sender_user_id == viewer.id
    )


def can_reply_thread(
    viewer: User,
    roles: Iterable[str],
    message: ProviderMessage,
) -> bool:
    role_set = set(roles)
    if ROLE_ADMIN in role_set:
        return True
    # The addressed provider (a doctor/therapist) may reply.
    if message.provider_user_id == viewer.id and (role_set & CLINICAL_ROLES):
        return True
    # The family member who started the thread may follow up.
    if message.sender_user_id == viewer.id and ROLE_FAMILY in role_set:
        return True
    return False


# --- queries -----------------------------------------------------------------


def list_provider_messages(
    session: Session,
    viewer: User,
    roles: Iterable[str],
    *,
    provider_user_id: Optional[uuid.UUID] = None,
    patient_profile_id: Optional[uuid.UUID] = None,
    limit: int = 50,
    offset: int = 0,
) -> Tuple[List[ProviderMessage], int]:
    # Which patient profiles the viewer may see (None == all/admin).
    visible = visible_patient_profile_ids(session, viewer, roles)

    conditions = [ProviderMessage.deleted_at.is_(None)]
    if visible is not None:
        # A thread about a patient the viewer can see, OR addressed to the viewer
        # as the provider, OR one the viewer started.
        conditions.append(
            or_(
                ProviderMessage.patient_profile_id.in_(visible),
                ProviderMessage.provider_user_id == viewer.id,
                ProviderMessage.sender_user_id == viewer.id,
            )
        )

    if provider_user_id is not None:
        conditions.append(ProviderMessage.provider_user_id == provider_user_id)
    if patient_profile_id is not None:
        conditions.append(
            ProviderMessage.patient_profile_id == patient_profile_id
        )

    total = session.execute(
        select(func.count()).select_from(ProviderMessage).where(*conditions)
    ).scalar_one()
    rows = (
        session.execute(
            select(ProviderMessage)
            .where(*conditions)
            .order_by(ProviderMessage.created_at.desc())
            .limit(limit)
            .offset(offset)
        )
        .scalars()
        .all()
    )
    return list(rows), int(total)


def reply_aggregates(
    session: Session,
    message_ids: List[uuid.UUID],
    viewer_id: uuid.UUID,
) -> Dict[uuid.UUID, dict]:
    """Per-thread latest-reply preview/time and viewer unread reply count."""
    if not message_ids:
        return {}
    replies = (
        session.execute(
            select(ProviderMessageReply)
            .where(
                ProviderMessageReply.provider_message_id.in_(message_ids),
                ProviderMessageReply.deleted_at.is_(None),
            )
            .order_by(ProviderMessageReply.created_at)
        )
        .scalars()
        .all()
    )
    agg: Dict[uuid.UUID, dict] = {}
    for r in replies:
        entry = agg.setdefault(
            r.provider_message_id,
            {"latest_preview": None, "latest_at": None, "unread": 0},
        )
        # Ascending order => the last one seen is the latest.
        entry["latest_preview"] = r.body[:_PREVIEW_CHARS]
        entry["latest_at"] = r.created_at
        if r.sender_user_id != viewer_id and r.read_at is None:
            entry["unread"] += 1
    return agg


def list_replies(
    session: Session, message_id: uuid.UUID
) -> List[ProviderMessageReply]:
    return list(
        session.execute(
            select(ProviderMessageReply)
            .where(
                ProviderMessageReply.provider_message_id == message_id,
                ProviderMessageReply.deleted_at.is_(None),
            )
            .order_by(ProviderMessageReply.created_at)
        )
        .scalars()
        .all()
    )


def unread_count(
    session: Session, viewer: User, roles: Iterable[str]
) -> int:
    """Total unread replies across every thread visible to the viewer."""
    visible = visible_patient_profile_ids(session, viewer, roles)

    thread_conditions = [ProviderMessage.deleted_at.is_(None)]
    if visible is not None:
        thread_conditions.append(
            or_(
                ProviderMessage.patient_profile_id.in_(visible),
                ProviderMessage.provider_user_id == viewer.id,
                ProviderMessage.sender_user_id == viewer.id,
            )
        )

    count = session.execute(
        select(func.count())
        .select_from(ProviderMessageReply)
        .join(
            ProviderMessage,
            ProviderMessage.id == ProviderMessageReply.provider_message_id,
        )
        .where(
            ProviderMessageReply.deleted_at.is_(None),
            ProviderMessageReply.sender_user_id != viewer.id,
            ProviderMessageReply.read_at.is_(None),
            *thread_conditions,
        )
    ).scalar_one()
    return int(count)


# --- mutations ---------------------------------------------------------------


def create_provider_message(
    session: Session,
    *,
    sender: User,
    roles: Iterable[str],
    provider_user_id: uuid.UUID,
    patient_profile_id: uuid.UUID,
    message: str,
    ip_address: Optional[str] = None,
    device_info: Optional[str] = None,
) -> ProviderMessage:
    role_set = set(roles)
    # Only a linked family member or an admin may send.
    if not (role_set & _CREATE_ROLES):
        raise NotAllowedError()

    profile = session.get(PatientProfile, patient_profile_id)
    if profile is None or profile.deleted_at is not None:
        raise ProfileNotFoundError()

    # Admins may send for any profile; a family member must be linked to it.
    if ROLE_ADMIN not in role_set and not can_view_profile(
        session, sender, role_set, profile
    ):
        raise NotAllowedError()

    # The provider must be an active doctor/therapist.
    provider = session.get(User, provider_user_id)
    if (
        provider is None
        or provider.deleted_at is not None
        or provider.status != "active"
        or not provider_roles(session, provider_user_id)
    ):
        raise ProviderNotFoundError()

    msg = ProviderMessage(
        provider_user_id=provider_user_id,
        sender_user_id=sender.id,
        patient_profile_id=patient_profile_id,
        message=message,
        status=STATUS_SENT,
    )
    session.add(msg)
    session.flush()
    record_audit(
        session,
        action="create_provider_message",
        entity_type="ProviderMessage",
        actor_user_id=sender.id,
        entity_id=msg.id,
        ip_address=ip_address,
        device_info=device_info,
        metadata={
            "provider_user_id": str(provider_user_id),
            "patient_profile_id": str(patient_profile_id),
        },
        commit=False,
    )
    session.commit()
    return msg


def create_reply(
    session: Session,
    *,
    message: ProviderMessage,
    sender: User,
    roles: Iterable[str],
    body: str,
    ip_address: Optional[str] = None,
    device_info: Optional[str] = None,
) -> ProviderMessageReply:
    if not can_reply_thread(sender, roles, message):
        raise NotAllowedError()

    reply = ProviderMessageReply(
        provider_message_id=message.id,
        sender_user_id=sender.id,
        body=body,
    )
    session.add(reply)

    # Reflect who last acted in the thread status (display only).
    if sender.id == message.provider_user_id:
        message.status = STATUS_ANSWERED
    else:
        message.status = STATUS_SENT
    session.add(message)

    session.flush()
    record_audit(
        session,
        action="create_provider_message_reply",
        entity_type="ProviderMessageReply",
        actor_user_id=sender.id,
        entity_id=reply.id,
        ip_address=ip_address,
        device_info=device_info,
        metadata={"provider_message_id": str(message.id)},
        commit=False,
    )
    session.commit()
    return reply


def mark_thread_read(
    session: Session, *, message: ProviderMessage, viewer: User
) -> int:
    """Mark replies in the thread the viewer didn't send as read. Returns count."""
    now = datetime.now(timezone.utc)
    result = session.execute(
        update(ProviderMessageReply)
        .where(
            ProviderMessageReply.provider_message_id == message.id,
            ProviderMessageReply.sender_user_id != viewer.id,
            ProviderMessageReply.read_at.is_(None),
            ProviderMessageReply.deleted_at.is_(None),
        )
        .values(read_at=now, read_by_user_id=viewer.id)
    )
    session.commit()
    return int(result.rowcount or 0)
