"""Provider + availability business logic.

Providers are active users with a doctor or therapist role. A ProviderProfile
adds display/booking detail (specialty, governorate/city, location, seeded demo
ratings, demo phone, uploaded photo). Visit modes, available-slot count, and the
next available date are derived from real availability. Optional filters (q,
role, governorate, mode, specialty) narrow the list.

DEMO USE: profile text, ratings, phone, and photos are seeded/uploaded demo
values only — not real clinicians. Scheduling/coordination content only.
"""

import uuid
from datetime import date, datetime, time, timezone
from typing import Dict, List, Optional, Tuple

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.permissions import ROLE_DOCTOR, ROLE_THERAPIST
from app.models import (
    Appointment,
    ProviderAvailabilitySlot,
    ProviderProfile,
    Role,
    User,
    UserRole,
)
from app.modules.providers import media

_PROVIDER_ROLES = (ROLE_DOCTOR, ROLE_THERAPIST)

_DEFAULT_FOCUS = {
    ROLE_DOCTOR: "Cognitive follow-up",
    ROLE_THERAPIST: "Therapy support",
}


class AvailabilityError(Exception):
    """Base class for provider availability management errors."""


class SlotNotFoundError(AvailabilityError):
    """The requested slot does not exist."""


class SlotNotOwnedError(AvailabilityError):
    """The provider does not own the requested slot."""


class InvalidSlotError(AvailabilityError):
    """The requested slot is not a valid future availability period."""


class OverlappingSlotError(AvailabilityError):
    """The requested slot overlaps existing provider availability."""


class ConsumedSlotError(AvailabilityError):
    """A booked slot cannot be removed."""


class ProviderDetail:
    """A provider plus profile + derived booking info (for the API response)."""

    def __init__(
        self,
        user: User,
        role: str,
        profile: ProviderProfile | None,
        slot_count: int,
        in_person: bool,
        online: bool,
        next_available_date: date | None,
    ):
        self.provider_user_id = user.id
        self.full_name = user.full_name
        self.role = role
        self.specialty = (
            profile.specialty
            if profile and profile.specialty
            else _DEFAULT_FOCUS.get(role)
        )
        self.bio_short = profile.bio_short if profile else None
        self.languages = [value for value in (profile.languages or "").split(",") if value] if profile else []
        self.clinic_name = profile.clinic_name if profile else None
        self.governorate = profile.governorate if profile else None
        self.city = profile.city if profile else None
        self.location = profile.location if profile else None
        self.experience_label = profile.experience_label if profile else None
        self.phone_number_demo = profile.phone_number_demo if profile else None
        self.photo_url = profile.photo_url if profile else None
        self.rating_average = profile.rating_average if profile else None
        self.rating_count = profile.rating_count if profile else None
        self.available_slot_count = slot_count
        self.in_person_available = in_person
        self.online_available = online
        self.next_available_date = next_available_date


def provider_roles(session: Session, user_id: uuid.UUID) -> set[str]:
    """The doctor/therapist role names held by `user_id` (may be empty)."""
    names = set(
        session.execute(
            select(Role.name)
            .join(UserRole, UserRole.role_id == Role.id)
            .where(UserRole.user_id == user_id)
        )
        .scalars()
        .all()
    )
    return names & set(_PROVIDER_ROLES)


def _base_providers(session: Session) -> List[Tuple[User, str]]:
    rows = session.execute(
        select(User, Role.name)
        .join(UserRole, UserRole.user_id == User.id)
        .join(Role, Role.id == UserRole.role_id)
        .where(
            Role.name.in_(_PROVIDER_ROLES),
            User.status == "active",
            User.deleted_at.is_(None),
        )
        .order_by(User.full_name)
    ).all()

    chosen: Dict[uuid.UUID, Tuple[User, str]] = {}
    for user, role_name in rows:
        if user.id not in chosen or role_name == ROLE_DOCTOR:
            chosen[user.id] = (user, role_name)
    return list(chosen.values())


def _availability_agg(
    session: Session, ids: List[uuid.UUID]
) -> Dict[uuid.UUID, dict]:
    today = date.today()
    if not ids:
        return {}
    slots = (
        session.execute(
            select(ProviderAvailabilitySlot).where(
                ProviderAvailabilitySlot.provider_user_id.in_(ids),
                ProviderAvailabilitySlot.is_available.is_(True),
                ProviderAvailabilitySlot.deleted_at.is_(None),
                ProviderAvailabilitySlot.slot_date >= today,
            )
        )
        .scalars()
        .all()
    )
    agg: Dict[uuid.UUID, dict] = {}
    for s in slots:
        entry = agg.setdefault(
            s.provider_user_id,
            {"count": 0, "in_person": False, "online": False, "min_date": None},
        )
        entry["count"] += 1
        if s.appointment_mode == "online":
            entry["online"] = True
        else:
            entry["in_person"] = True
        if entry["min_date"] is None or s.slot_date < entry["min_date"]:
            entry["min_date"] = s.slot_date
    return agg


def _detail(
    session: Session, user: User, role: str, agg_entry: dict | None
) -> ProviderDetail:
    profile = session.execute(
        select(ProviderProfile).where(
            ProviderProfile.provider_user_id == user.id,
            ProviderProfile.deleted_at.is_(None),
        )
    ).scalar_one_or_none()
    a = agg_entry or {
        "count": 0,
        "in_person": False,
        "online": False,
        "min_date": None,
    }
    return ProviderDetail(
        user=user,
        role=role,
        profile=profile,
        slot_count=a["count"],
        in_person=a["in_person"],
        online=a["online"],
        next_available_date=a["min_date"],
    )


def list_providers(
    session: Session,
    *,
    q: Optional[str] = None,
    role: Optional[str] = None,
    governorate: Optional[str] = None,
    mode: Optional[str] = None,
    specialty: Optional[str] = None,
) -> List[ProviderDetail]:
    base = _base_providers(session)
    agg = _availability_agg(session, [u.id for u, _ in base])
    details = [_detail(session, u, r, agg.get(u.id)) for u, r in base]

    q_lc = q.strip().lower() if q else None
    gov_lc = governorate.strip().lower() if governorate else None

    def keep(d: ProviderDetail) -> bool:
        if role and d.role != role:
            return False
        if gov_lc and (d.governorate or "").lower() != gov_lc:
            return False
        if specialty and (d.specialty or "") != specialty:
            return False
        if mode == "in_person" and not d.in_person_available:
            return False
        if mode == "online" and not d.online_available:
            return False
        if q_lc:
            hay = " ".join(
                [
                    d.full_name,
                    d.specialty or "",
                    d.city or "",
                    d.governorate or "",
                ]
            ).lower()
            if q_lc not in hay:
                return False
        return True

    return [d for d in details if keep(d)]


def get_provider_detail(
    session: Session, provider_id: uuid.UUID
) -> Optional[ProviderDetail]:
    user = session.get(User, provider_id)
    if user is None or user.deleted_at is not None:
        return None
    roles = provider_roles(session, provider_id)
    if not roles:
        return None
    role = ROLE_DOCTOR if ROLE_DOCTOR in roles else ROLE_THERAPIST
    agg = _availability_agg(session, [provider_id])
    return _detail(session, user, role, agg.get(provider_id))


def set_provider_photo(
    session: Session,
    provider_id: uuid.UUID,
    data: bytes,
    extension: str,
) -> str:
    """Store an uploaded photo and point the provider profile at it.

    Creates a minimal profile if the provider has none. Replaces (and cleans up)
    a previous local photo. Returns the new public photo URL.
    """
    profile = session.execute(
        select(ProviderProfile).where(
            ProviderProfile.provider_user_id == provider_id,
            ProviderProfile.deleted_at.is_(None),
        )
    ).scalar_one_or_none()
    if profile is None:
        profile = ProviderProfile(provider_user_id=provider_id)
        session.add(profile)
        session.flush()

    previous = profile.photo_url
    filename = media.save_image_bytes(data, extension)
    profile.photo_url = media.public_url(filename)
    session.add(profile)
    session.commit()

    if previous and previous != profile.photo_url:
        media.delete_local_media(previous)
    return profile.photo_url


def update_self_profile(session: Session, user: User, changes: dict) -> ProviderDetail:
    """Update only editable professional fields for an authenticated provider."""
    if "display_name" in changes:
        user.full_name = changes.pop("display_name")
        session.add(user)
    profile = session.execute(
        select(ProviderProfile).where(
            ProviderProfile.provider_user_id == user.id,
            ProviderProfile.deleted_at.is_(None),
        )
    ).scalar_one_or_none()
    if profile is None:
        profile = ProviderProfile(provider_user_id=user.id)
    if "languages" in changes:
        changes["languages"] = ",".join(changes["languages"] or []) or None
    for field in ("specialty", "bio_short", "languages", "clinic_name", "location"):
        if field in changes:
            setattr(profile, field, changes[field])
    session.add(profile)
    session.commit()
    detail = get_provider_detail(session, user.id)
    assert detail is not None
    return detail


def get_available_slots(
    session: Session, provider_user_id: uuid.UUID
) -> List[ProviderAvailabilitySlot]:
    today = date.today()
    return list(
        session.execute(
            select(ProviderAvailabilitySlot)
            .where(
                ProviderAvailabilitySlot.provider_user_id == provider_user_id,
                ProviderAvailabilitySlot.is_available.is_(True),
                ProviderAvailabilitySlot.deleted_at.is_(None),
                ProviderAvailabilitySlot.slot_date >= today,
            )
            .order_by(
                ProviderAvailabilitySlot.slot_date,
                ProviderAvailabilitySlot.start_time,
            )
        )
        .scalars()
        .all()
    )


def list_own_slots(
    session: Session, provider_user_id: uuid.UUID
) -> List[ProviderAvailabilitySlot]:
    """List the provider's non-deleted future slots, including consumed slots."""
    today = date.today()
    return list(
        session.execute(
            select(ProviderAvailabilitySlot)
            .where(
                ProviderAvailabilitySlot.provider_user_id == provider_user_id,
                ProviderAvailabilitySlot.deleted_at.is_(None),
                ProviderAvailabilitySlot.slot_date >= today,
            )
            .order_by(
                ProviderAvailabilitySlot.slot_date,
                ProviderAvailabilitySlot.start_time,
            )
        )
        .scalars()
        .all()
    )


def create_own_slot(
    session: Session,
    provider_user_id: uuid.UUID,
    *,
    slot_date: date,
    start_time: time,
    end_time: time,
    appointment_mode: str,
    location: Optional[str] = None,
    meeting_url: Optional[str] = None,
) -> ProviderAvailabilitySlot:
    now = datetime.now()
    starts_at = datetime.combine(slot_date, start_time)
    if starts_at <= now:
        raise InvalidSlotError()

    start_value = start_time.strftime("%H:%M")
    end_value = end_time.strftime("%H:%M")
    overlap = session.execute(
        select(ProviderAvailabilitySlot.id).where(
            ProviderAvailabilitySlot.provider_user_id == provider_user_id,
            ProviderAvailabilitySlot.slot_date == slot_date,
            ProviderAvailabilitySlot.deleted_at.is_(None),
            ProviderAvailabilitySlot.start_time < end_value,
            ProviderAvailabilitySlot.end_time > start_value,
        )
    ).first()
    if overlap is not None:
        raise OverlappingSlotError()

    slot = ProviderAvailabilitySlot(
        provider_user_id=provider_user_id,
        slot_date=slot_date,
        start_time=start_value,
        end_time=end_value,
        appointment_mode=appointment_mode,
        location=location,
        meeting_url=meeting_url,
        is_available=True,
    )
    session.add(slot)
    session.commit()
    return slot


def remove_own_slot(
    session: Session, provider_user_id: uuid.UUID, slot_id: uuid.UUID
) -> None:
    slot = session.get(ProviderAvailabilitySlot, slot_id)
    if slot is None or slot.deleted_at is not None:
        raise SlotNotFoundError()
    if slot.provider_user_id != provider_user_id:
        raise SlotNotOwnedError()

    starts_at = datetime.combine(slot.slot_date, time.fromisoformat(slot.start_time))
    if starts_at <= datetime.now():
        raise InvalidSlotError()

    booked = session.execute(
        select(Appointment.id).where(
            Appointment.availability_slot_id == slot.id,
            Appointment.deleted_at.is_(None),
        )
    ).first()
    if not slot.is_available or booked is not None:
        raise ConsumedSlotError()

    slot.deleted_at = datetime.now(timezone.utc)
    session.add(slot)
    session.commit()
