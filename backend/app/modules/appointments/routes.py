"""Appointment routes.

- Listing: any authenticated active user, scoped by role (patient=own,
  family=linked, doctor/therapist=assigned or provider, admin=all).
- Creating: a linked family member or an admin only, by booking a provider's
  available slot.
- Updating status: admin, the appointment's provider, or a clinician assigned to
  the patient.

MEDICAL SAFETY: coordination content only — appointment requests are never
emergency care, diagnosis, assessment, or treatment.
"""

import uuid
from contextlib import contextmanager
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models import Appointment, User
from app.modules.appointments import service
from app.modules.appointments.schemas import (
    AppointmentCreate,
    AppointmentListResponse,
    AppointmentResponse,
    AppointmentStatusUpdate,
)
from app.modules.auth.dependencies import get_current_active_user
from app.modules.auth.service import get_role_names

router = APIRouter(prefix="/api/v1/appointments", tags=["appointments"])


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
    except service.SlotNotAvailableError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Selected time slot is no longer available.",
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


def _appt_response(db: Session, appt: Appointment) -> AppointmentResponse:
    resp = AppointmentResponse.model_validate(appt)
    if appt.provider_user_id is not None:
        provider = db.get(User, appt.provider_user_id)
        if provider is not None:
            resp.provider_name = provider.full_name
    return resp


def _require_appointment(db: Session, appointment_id: uuid.UUID) -> Appointment:
    appt = service.get_appointment(db, appointment_id)
    if appt is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Appointment not found."
        )
    return appt


@router.get("", response_model=AppointmentListResponse)
def list_appointments(
    patient_profile_id: Optional[uuid.UUID] = Query(default=None),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> AppointmentListResponse:
    roles = get_role_names(db, current_user.id)
    items, total = service.list_appointments(
        db,
        current_user,
        roles,
        patient_profile_id=patient_profile_id,
        limit=limit,
        offset=offset,
    )
    return AppointmentListResponse(
        total=total,
        limit=limit,
        offset=offset,
        appointments=[_appt_response(db, i) for i in items],
    )


@router.post(
    "",
    response_model=AppointmentResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_appointment(
    payload: AppointmentCreate,
    request: Request,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> AppointmentResponse:
    roles = get_role_names(db, current_user.id)
    ip_address, device_info = _client_info(request)
    with _translate_errors():
        appointment = service.create_appointment(
            db,
            requester=current_user,
            roles=roles,
            patient_profile_id=payload.patient_profile_id,
            provider_user_id=payload.provider_user_id,
            availability_slot_id=payload.availability_slot_id,
            reason=payload.reason,
            ip_address=ip_address,
            device_info=device_info,
        )
    return _appt_response(db, appointment)


@router.patch("/{appointment_id}/status", response_model=AppointmentResponse)
def update_appointment_status(
    appointment_id: uuid.UUID,
    payload: AppointmentStatusUpdate,
    request: Request,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> AppointmentResponse:
    appointment = _require_appointment(db, appointment_id)
    roles = get_role_names(db, current_user.id)
    ip_address, device_info = _client_info(request)
    with _translate_errors():
        appointment = service.update_status(
            db,
            appointment=appointment,
            editor=current_user,
            roles=roles,
            status=payload.status,
            ip_address=ip_address,
            device_info=device_info,
        )
    return _appt_response(db, appointment)
