"""Provider + availability routes.

- GET /api/v1/providers — list bookable providers, with optional filters
  (q, role, governorate, mode, specialty). Any authenticated active user.
- GET /api/v1/providers/{id} — a single provider's detail.
- GET /api/v1/providers/{id}/availability — available slots for a provider.
- POST /api/v1/providers/{id}/photo — upload a demo photo (admin only).

DEMO USE: provider profiles/ratings/photos are seeded/uploaded demo values only.
Scheduling/coordination content only.
"""

import uuid
from typing import Optional

from fastapi import (
    APIRouter,
    Depends,
    File,
    HTTPException,
    Query,
    Response,
    UploadFile,
    status,
)
from sqlalchemy.orm import Session

from app.core.permissions import ROLE_ADMIN, ROLE_DOCTOR, ROLE_THERAPIST
from app.db.session import get_db
from app.models import User
from app.modules.auth.dependencies import get_current_active_user, require_roles
from app.modules.providers import media, service
from app.modules.providers.schemas import (
    ProviderListResponse,
    ProviderManagedSlotListResponse,
    ProviderManagedSlotResponse,
    ProviderResponse,
    ProviderSelfUpdate,
    ProviderSlotCreate,
    SlotListResponse,
    SlotResponse,
)

router = APIRouter(prefix="/api/v1/providers", tags=["providers"])

admin_required = require_roles([ROLE_ADMIN])
provider_required = require_roles([ROLE_DOCTOR, ROLE_THERAPIST])


def _translate_availability_error(error: service.AvailabilityError) -> HTTPException:
    if isinstance(error, service.SlotNotOwnedError):
        return HTTPException(status_code=403, detail="You may manage only your own availability slots.")
    if isinstance(error, service.SlotNotFoundError):
        return HTTPException(status_code=404, detail="Availability slot not found.")
    if isinstance(error, service.ConsumedSlotError):
        return HTTPException(status_code=409, detail="A booked availability slot cannot be removed.")
    if isinstance(error, service.OverlappingSlotError):
        return HTTPException(status_code=409, detail="The availability slot overlaps an existing slot.")
    return HTTPException(status_code=400, detail="The availability slot must be in the future.")


@router.get("", response_model=ProviderListResponse)
def list_providers(
    q: Optional[str] = Query(default=None),
    role: Optional[str] = Query(default=None),
    governorate: Optional[str] = Query(default=None),
    mode: Optional[str] = Query(default=None),
    specialty: Optional[str] = Query(default=None),
    _current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> ProviderListResponse:
    items = service.list_providers(
        db,
        q=q,
        role=role,
        governorate=governorate,
        mode=mode,
        specialty=specialty,
    )
    return ProviderListResponse(
        providers=[ProviderResponse.model_validate(d) for d in items]
    )


@router.get("/me", response_model=ProviderResponse)
def get_self_profile(
    current_user: User = Depends(provider_required),
    db: Session = Depends(get_db),
) -> ProviderResponse:
    detail = service.get_provider_detail(db, current_user.id)
    if detail is None:
        raise HTTPException(status_code=404, detail="Provider profile not found.")
    return ProviderResponse.model_validate(detail)


@router.patch("/me", response_model=ProviderResponse)
def update_self_profile(
    payload: ProviderSelfUpdate,
    current_user: User = Depends(provider_required),
    db: Session = Depends(get_db),
) -> ProviderResponse:
    detail = service.update_self_profile(db, current_user, payload.model_dump(exclude_unset=True))
    return ProviderResponse.model_validate(detail)


@router.post("/me/photo", response_model=ProviderResponse)
async def upload_self_photo(
    file: UploadFile = File(...),
    current_user: User = Depends(provider_required),
    db: Session = Depends(get_db),
) -> ProviderResponse:
    extension = media.extension_for(file.content_type)
    if extension is None:
        raise HTTPException(status_code=400, detail="Unsupported file type. Allowed: JPEG, PNG, WebP images.")
    data = await file.read()
    if not data:
        raise HTTPException(status_code=400, detail="The file is empty.")
    if len(data) > media.MAX_UPLOAD_BYTES:
        raise HTTPException(status_code=status.HTTP_413_CONTENT_TOO_LARGE, detail="The file is too large (maximum 5 MB).")
    service.set_provider_photo(db, current_user.id, data, extension)
    detail = service.get_provider_detail(db, current_user.id)
    assert detail is not None
    return ProviderResponse.model_validate(detail)


@router.get("/me/availability", response_model=ProviderManagedSlotListResponse)
def list_self_availability(
    current_user: User = Depends(provider_required),
    db: Session = Depends(get_db),
) -> ProviderManagedSlotListResponse:
    slots = service.list_own_slots(db, current_user.id)
    return ProviderManagedSlotListResponse(
        slots=[ProviderManagedSlotResponse.model_validate(slot) for slot in slots]
    )


@router.post(
    "/me/availability",
    response_model=ProviderManagedSlotResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_self_availability(
    payload: ProviderSlotCreate,
    current_user: User = Depends(provider_required),
    db: Session = Depends(get_db),
) -> ProviderManagedSlotResponse:
    try:
        slot = service.create_own_slot(
            db, current_user.id, **payload.model_dump()
        )
    except service.AvailabilityError as error:
        raise _translate_availability_error(error)
    return ProviderManagedSlotResponse.model_validate(slot)


@router.delete(
    "/me/availability/{slot_id}", status_code=status.HTTP_204_NO_CONTENT
)
def delete_self_availability(
    slot_id: uuid.UUID,
    current_user: User = Depends(provider_required),
    db: Session = Depends(get_db),
) -> Response:
    try:
        service.remove_own_slot(db, current_user.id, slot_id)
    except service.AvailabilityError as error:
        raise _translate_availability_error(error)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.get("/{provider_id}", response_model=ProviderResponse)
def get_provider(
    provider_id: uuid.UUID,
    _current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> ProviderResponse:
    detail = service.get_provider_detail(db, provider_id)
    if detail is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Provider not found."
        )
    return ProviderResponse.model_validate(detail)


@router.get("/{provider_id}/availability", response_model=SlotListResponse)
def provider_availability(
    provider_id: uuid.UUID,
    _current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> SlotListResponse:
    slots = service.get_available_slots(db, provider_id)
    return SlotListResponse(slots=[SlotResponse.model_validate(s) for s in slots])


@router.post("/{provider_id}/photo", response_model=ProviderResponse)
async def upload_provider_photo(
    provider_id: uuid.UUID,
    file: UploadFile = File(...),
    _admin: User = Depends(admin_required),
    db: Session = Depends(get_db),
) -> ProviderResponse:
    """Upload a demo photo for a provider (admin only)."""
    # The target must be an actual doctor/therapist provider.
    if not service.provider_roles(db, provider_id):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Provider not found."
        )

    extension = media.extension_for(file.content_type)
    if extension is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Unsupported file type. Allowed: JPEG, PNG, WebP images.",
        )

    data = await file.read()
    if not data:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="The file is empty."
        )
    if len(data) > media.MAX_UPLOAD_BYTES:
        raise HTTPException(
            status_code=status.HTTP_413_CONTENT_TOO_LARGE,
            detail="The file is too large (maximum 5 MB).",
        )

    service.set_provider_photo(db, provider_id, data, extension)
    detail = service.get_provider_detail(db, provider_id)
    if detail is None:  # pragma: no cover - provider validated above
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Provider not found."
        )
    return ProviderResponse.model_validate(detail)
