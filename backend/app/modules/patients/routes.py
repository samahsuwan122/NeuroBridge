"""Patient profile routes.

Mutations (create/update/assign/link/deactivate) are admin-only. Reads
(list/get) are available to any authenticated active user but are scoped by role
(admin=all, manager=same center, doctor/therapist=assigned, patient=own,
family=linked). Responses never include password_hash.
"""

import uuid
from contextlib import contextmanager

from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from sqlalchemy.orm import Session

from app.core.permissions import ROLE_ADMIN
from app.db.session import get_db
from app.models import PatientAssignment, PatientFamilyLink, PatientProfile, User
from app.modules.auth.dependencies import get_current_active_user, require_roles
from app.modules.auth.schemas import UserBasic
from app.modules.auth.service import get_role_names
from app.modules.patients import service
from app.modules.patients.schemas import (
    AssignClinicianRequest,
    LinkFamilyRequest,
    MessageResponse,
    PatientAssignmentResponse,
    PatientFamilyLinkResponse,
    PatientProfileCreate,
    PatientProfileListResponse,
    PatientProfileResponse,
    PatientProfileUpdate,
)

router = APIRouter(prefix="/api/v1/patients", tags=["patients"])

admin_required = require_roles([ROLE_ADMIN])


@contextmanager
def _translate_patient_errors():
    """Map patient domain errors to HTTP responses."""
    try:
        yield
    except service.UserNotFoundError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="Referenced user not found."
        )
    except service.NotPatientRoleError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="The user does not have the patient role.",
        )
    except service.DuplicateProfileError:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="This user already has a patient profile.",
        )
    except service.WrongClinicianRoleError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="The user does not have the required doctor/therapist role.",
        )
    except service.WrongFamilyRoleError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="The user does not have the family role.",
        )
    except service.RelationshipNotFoundError:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Relationship not found."
        )


def _client_info(request: Request) -> tuple[str | None, str | None]:
    ip_address = request.client.host if request.client else None
    device_info = request.headers.get("user-agent")
    return ip_address, device_info


def _assignment_response(a: PatientAssignment) -> PatientAssignmentResponse:
    return PatientAssignmentResponse.model_validate(a)


def _family_response(link: PatientFamilyLink) -> PatientFamilyLinkResponse:
    return PatientFamilyLinkResponse.model_validate(link)


def _profile_response(db: Session, profile: PatientProfile) -> PatientProfileResponse:
    user = db.get(User, profile.user_id)
    assignments = service.get_assignments(db, profile.id)
    links = service.get_family_links(db, profile.id)
    return PatientProfileResponse(
        id=profile.id,
        user_id=profile.user_id,
        user=UserBasic.model_validate(user) if user is not None else None,
        medical_center_id=profile.medical_center_id,
        date_of_birth=profile.date_of_birth,
        gender=profile.gender,
        emergency_contact_name=profile.emergency_contact_name,
        emergency_contact_phone=profile.emergency_contact_phone,
        notes=profile.notes,
        assignments=[_assignment_response(a) for a in assignments],
        family_links=[_family_response(link) for link in links],
        created_at=profile.created_at,
        updated_at=profile.updated_at,
    )


def _require_profile(db: Session, profile_id: uuid.UUID) -> PatientProfile:
    profile = service.get_profile(db, profile_id)
    if profile is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Patient profile not found."
        )
    return profile


@router.post("", response_model=PatientProfileResponse, status_code=status.HTTP_201_CREATED)
def create_patient_profile(
    payload: PatientProfileCreate,
    request: Request,
    admin: User = Depends(admin_required),
    db: Session = Depends(get_db),
) -> PatientProfileResponse:
    ip_address, device_info = _client_info(request)
    with _translate_patient_errors():
        profile = service.create_patient_profile(
            db,
            user_id=payload.user_id,
            medical_center_id=payload.medical_center_id,
            date_of_birth=payload.date_of_birth,
            gender=payload.gender,
            emergency_contact_name=payload.emergency_contact_name,
            emergency_contact_phone=payload.emergency_contact_phone,
            notes=payload.notes,
            actor_user_id=admin.id,
            ip_address=ip_address,
            device_info=device_info,
        )
    return _profile_response(db, profile)


@router.get("", response_model=PatientProfileListResponse)
def list_patient_profiles(
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> PatientProfileListResponse:
    roles = get_role_names(db, current_user.id)
    profiles, total = service.list_profiles(db, current_user, roles, limit, offset)
    return PatientProfileListResponse(
        total=total,
        limit=limit,
        offset=offset,
        patients=[_profile_response(db, p) for p in profiles],
    )


@router.get("/{patient_profile_id}", response_model=PatientProfileResponse)
def get_patient_profile(
    patient_profile_id: uuid.UUID,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> PatientProfileResponse:
    profile = _require_profile(db, patient_profile_id)
    roles = get_role_names(db, current_user.id)
    if not service.can_view_profile(db, current_user, roles, profile):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You are not allowed to view this patient.",
        )
    return _profile_response(db, profile)


@router.put("/{patient_profile_id}", response_model=PatientProfileResponse)
def update_patient_profile(
    patient_profile_id: uuid.UUID,
    payload: PatientProfileUpdate,
    request: Request,
    admin: User = Depends(admin_required),
    db: Session = Depends(get_db),
) -> PatientProfileResponse:
    profile = _require_profile(db, patient_profile_id)
    fields = payload.model_dump(exclude_unset=True)
    ip_address, device_info = _client_info(request)
    with _translate_patient_errors():
        profile = service.update_patient_profile(
            db,
            profile=profile,
            fields=fields,
            actor_user_id=admin.id,
            ip_address=ip_address,
            device_info=device_info,
        )
    return _profile_response(db, profile)


@router.post(
    "/{patient_profile_id}/assign-clinician",
    response_model=PatientAssignmentResponse,
    status_code=status.HTTP_201_CREATED,
)
def assign_clinician(
    patient_profile_id: uuid.UUID,
    payload: AssignClinicianRequest,
    request: Request,
    admin: User = Depends(admin_required),
    db: Session = Depends(get_db),
) -> PatientAssignmentResponse:
    profile = _require_profile(db, patient_profile_id)
    ip_address, device_info = _client_info(request)
    with _translate_patient_errors():
        assignment = service.assign_clinician(
            db,
            profile=profile,
            clinician_user_id=payload.clinician_user_id,
            assignment_type=payload.assignment_type,
            actor_user_id=admin.id,
            ip_address=ip_address,
            device_info=device_info,
        )
    return _assignment_response(assignment)


@router.post(
    "/{patient_profile_id}/link-family",
    response_model=PatientFamilyLinkResponse,
    status_code=status.HTTP_201_CREATED,
)
def link_family(
    patient_profile_id: uuid.UUID,
    payload: LinkFamilyRequest,
    request: Request,
    admin: User = Depends(admin_required),
    db: Session = Depends(get_db),
) -> PatientFamilyLinkResponse:
    profile = _require_profile(db, patient_profile_id)
    ip_address, device_info = _client_info(request)
    with _translate_patient_errors():
        link = service.link_family(
            db,
            profile=profile,
            family_user_id=payload.family_user_id,
            relationship=payload.relationship,
            actor_user_id=admin.id,
            ip_address=ip_address,
            device_info=device_info,
        )
    return _family_response(link)


@router.post(
    "/{patient_profile_id}/assignments/{assignment_id}/deactivate",
    response_model=MessageResponse,
)
def deactivate_assignment(
    patient_profile_id: uuid.UUID,
    assignment_id: uuid.UUID,
    request: Request,
    admin: User = Depends(admin_required),
    db: Session = Depends(get_db),
) -> MessageResponse:
    profile = _require_profile(db, patient_profile_id)
    ip_address, device_info = _client_info(request)
    with _translate_patient_errors():
        service.deactivate_assignment(
            db,
            profile=profile,
            assignment_id=assignment_id,
            actor_user_id=admin.id,
            ip_address=ip_address,
            device_info=device_info,
        )
    return MessageResponse(message="Assignment deactivated.")


@router.post(
    "/{patient_profile_id}/family-links/{link_id}/deactivate",
    response_model=MessageResponse,
)
def deactivate_family_link(
    patient_profile_id: uuid.UUID,
    link_id: uuid.UUID,
    request: Request,
    admin: User = Depends(admin_required),
    db: Session = Depends(get_db),
) -> MessageResponse:
    profile = _require_profile(db, patient_profile_id)
    ip_address, device_info = _client_info(request)
    with _translate_patient_errors():
        service.deactivate_family_link(
            db,
            profile=profile,
            link_id=link_id,
            actor_user_id=admin.id,
            ip_address=ip_address,
            device_info=device_info,
        )
    return MessageResponse(message="Family link deactivated.")
