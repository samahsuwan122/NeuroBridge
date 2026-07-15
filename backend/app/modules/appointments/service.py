"""Appointment business logic and access control.

HTTP-free: routes translate the domain exceptions below into HTTP responses.
Access reuses the patient-profile visibility rules so RBAC lives in one place.

MEDICAL SAFETY: coordination content only. Appointment requests are never
emergency care, diagnosis, assessment, or treatment.

Access model:
- View (list): admin=all; otherwise appointments for a patient the viewer may
  see (family=linked, patient=own, doctor/therapist=assigned) OR appointments
  where the viewer is the chosen provider.
- Create: a linked family member or an admin only. The provider, date/time, mode,
  and location come from the booked slot; status is set by the backend
  ("pending"); requesters cannot choose it.
- Update status: admin, the appointment's provider, or a clinician assigned to
  the patient. Cancelling reopens the booked slot.
"""

import uuid
from typing import Iterable, List, Optional, Tuple

from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from app.core.permissions import CLINICAL_ROLES, ROLE_ADMIN, ROLE_FAMILY
from app.models import (
    Appointment,
    PatientProfile,
    ProviderAvailabilitySlot,
    User,
)
from app.modules.audit.service import record_audit
from app.modules.patients.service import (
    can_view_profile,
    visible_patient_profile_ids,
)
from app.modules.providers.service import provider_roles

STATUS_PENDING = "pending"
STATUS_CANCELLED = "cancelled"


# --- domain exceptions -------------------------------------------------------


class AppointmentError(Exception):
    """Base class for appointment domain errors."""


class ProfileNotFoundError(AppointmentError):
    """The referenced patient profile does not exist."""


class ProviderNotFoundError(AppointmentError):
    """The referenced provider does not exist or is not a care provider."""


class SlotNotAvailableError(AppointmentError):
    """The referenced availability slot is missing or already taken."""


class NotAllowedError(AppointmentError):
    """The user is not allowed to perform this action."""


# Only a linked family member or an admin may create appointment requests.
_CREATE_ROLES = frozenset({ROLE_FAMILY, ROLE_ADMIN})


# --- queries -----------------------------------------------------------------


def get_appointment(
    session: Session, appointment_id: uuid.UUID
) -> Optional[Appointment]:
    appt = session.get(Appointment, appointment_id)
    if appt is None or appt.deleted_at is not None:
        return None
    return appt


def list_appointments(
    session: Session,
    viewer: User,
    roles: Iterable[str],
    *,
    patient_profile_id: Optional[uuid.UUID] = None,
    limit: int = 50,
    offset: int = 0,
) -> Tuple[List[Appointment], int]:
    # Which patient profiles the viewer may see (None == all/admin).
    visible = visible_patient_profile_ids(session, viewer, roles)

    conditions = [Appointment.deleted_at.is_(None)]
    if visible is not None:
        # A patient the viewer can see, OR an appointment they are the provider
        # for (a doctor/therapist chosen for the booking).
        conditions.append(
            or_(
                Appointment.patient_profile_id.in_(visible),
                Appointment.provider_user_id == viewer.id,
            )
        )

    if patient_profile_id is not None:
        conditions.append(Appointment.patient_profile_id == patient_profile_id)

    total = session.execute(
        select(func.count()).select_from(Appointment).where(*conditions)
    ).scalar_one()
    rows = (
        session.execute(
            select(Appointment)
            .where(*conditions)
            .order_by(Appointment.created_at.desc())
            .limit(limit)
            .offset(offset)
        )
        .scalars()
        .all()
    )
    return list(rows), int(total)


# --- mutations ---------------------------------------------------------------


def create_appointment(
    session: Session,
    *,
    requester: User,
    roles: Iterable[str],
    patient_profile_id: uuid.UUID,
    provider_user_id: uuid.UUID,
    availability_slot_id: uuid.UUID,
    reason: str,
    ip_address: Optional[str] = None,
    device_info: Optional[str] = None,
) -> Appointment:
    role_set = set(roles)
    # Only a linked family member or an admin may request.
    if not (role_set & _CREATE_ROLES):
        raise NotAllowedError()

    profile = session.get(PatientProfile, patient_profile_id)
    if profile is None or profile.deleted_at is not None:
        raise ProfileNotFoundError()

    # Admins may request for any profile; a family member must be linked to it.
    if ROLE_ADMIN not in role_set and not can_view_profile(
        session, requester, role_set, profile
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

    # The slot must exist, belong to the provider, and still be available.
    slot = session.get(ProviderAvailabilitySlot, availability_slot_id)
    if (
        slot is None
        or slot.deleted_at is not None
        or slot.provider_user_id != provider_user_id
        or not slot.is_available
    ):
        raise SlotNotAvailableError()

    appointment = Appointment(
        patient_profile_id=patient_profile_id,
        requester_user_id=requester.id,
        provider_user_id=provider_user_id,
        availability_slot_id=slot.id,
        preferred_date=slot.slot_date,
        preferred_time=slot.start_time,
        appointment_mode=slot.appointment_mode,
        location=slot.location,
        meeting_url=slot.meeting_url,
        reason=reason,
        status=STATUS_PENDING,
    )
    session.add(appointment)
    # Booking consumes the slot so it is not double-booked.
    slot.is_available = False
    session.add(slot)
    session.flush()
    record_audit(
        session,
        action="create_appointment_request",
        entity_type="Appointment",
        actor_user_id=requester.id,
        entity_id=appointment.id,
        ip_address=ip_address,
        device_info=device_info,
        metadata={
            "patient_profile_id": str(patient_profile_id),
            "provider_user_id": str(provider_user_id),
        },
        commit=False,
    )
    session.commit()
    return appointment


def can_update_status(
    session: Session,
    editor: User,
    roles: Iterable[str],
    appointment: Appointment,
) -> bool:
    """Admin, the appointment's provider, or a clinician assigned to the patient."""
    role_set = set(roles)
    if ROLE_ADMIN in role_set:
        return True
    if not (role_set & CLINICAL_ROLES):
        return False
    if appointment.provider_user_id == editor.id:
        return True
    profile = session.get(PatientProfile, appointment.patient_profile_id)
    if profile is None or profile.deleted_at is not None:
        return False
    return can_view_profile(session, editor, role_set, profile)


def update_status(
    session: Session,
    *,
    appointment: Appointment,
    editor: User,
    roles: Iterable[str],
    status: str,
    ip_address: Optional[str] = None,
    device_info: Optional[str] = None,
) -> Appointment:
    if not can_update_status(session, editor, roles, appointment):
        raise NotAllowedError()

    previous = appointment.status
    appointment.status = status
    session.add(appointment)

    # Cancelling frees the booked slot again.
    if status == STATUS_CANCELLED and appointment.availability_slot_id:
        slot = session.get(
            ProviderAvailabilitySlot, appointment.availability_slot_id
        )
        if slot is not None and not slot.is_available:
            slot.is_available = True
            session.add(slot)

    record_audit(
        session,
        action="update_appointment_status",
        entity_type="Appointment",
        actor_user_id=editor.id,
        entity_id=appointment.id,
        ip_address=ip_address,
        device_info=device_info,
        metadata={"from": previous, "to": status},
        commit=False,
    )
    session.commit()
    return appointment
