"""Memory Album routes.

- Listing/getting memories: any authenticated active user, scoped by role
  (admin=all, doctor/therapist=assigned, patient=own, family=linked,
  manager=same center).
- Creating memories: patient (own profile), linked family, or admin only.
- Updating/deleting: creator or admin only.

MEDICAL SAFETY: memories are supportive/family-engagement content only — no
diagnosis, scoring, or medical interpretation.
"""

import uuid
from contextlib import contextmanager
from typing import Optional

from fastapi import (
    APIRouter,
    Depends,
    File,
    HTTPException,
    Query,
    Request,
    UploadFile,
    status,
)
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models import MemoryEntry, User
from app.modules.auth.dependencies import get_current_active_user
from app.modules.auth.service import get_role_names
from app.modules.memories import media, service
from app.modules.memories.schemas import (
    MemoryEntryCreate,
    MemoryEntryResponse,
    MemoryEntryUpdate,
    MemoryListResponse,
    MessageResponse,
)

router = APIRouter(prefix="/api/v1/memories", tags=["memories"])


@contextmanager
def _translate_memory_errors():
    try:
        yield
    except service.ProfileNotFoundError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Patient profile not found.",
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


def _memory_response(memory: MemoryEntry) -> MemoryEntryResponse:
    return MemoryEntryResponse.model_validate(memory)


def _require_memory(db: Session, memory_id: uuid.UUID) -> MemoryEntry:
    memory = service.get_memory(db, memory_id)
    if memory is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Memory not found."
        )
    return memory


@router.get("", response_model=MemoryListResponse)
def list_memories(
    patient_profile_id: Optional[uuid.UUID] = Query(default=None),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> MemoryListResponse:
    roles = get_role_names(db, current_user.id)
    memories, total = service.list_memories(
        db,
        current_user,
        roles,
        patient_profile_id=patient_profile_id,
        limit=limit,
        offset=offset,
    )
    return MemoryListResponse(
        total=total,
        limit=limit,
        offset=offset,
        memories=[_memory_response(m) for m in memories],
    )


@router.post("", response_model=MemoryEntryResponse, status_code=status.HTTP_201_CREATED)
def create_memory(
    payload: MemoryEntryCreate,
    request: Request,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> MemoryEntryResponse:
    roles = get_role_names(db, current_user.id)
    ip_address, device_info = _client_info(request)
    fields = payload.model_dump(exclude={"patient_profile_id", "title"})
    with _translate_memory_errors():
        memory = service.create_memory(
            db,
            creator=current_user,
            roles=roles,
            patient_profile_id=payload.patient_profile_id,
            title=payload.title,
            fields=fields,
            ip_address=ip_address,
            device_info=device_info,
        )
    return _memory_response(memory)


@router.get("/{memory_id}", response_model=MemoryEntryResponse)
def get_memory(
    memory_id: uuid.UUID,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> MemoryEntryResponse:
    memory = _require_memory(db, memory_id)
    roles = get_role_names(db, current_user.id)
    if not service.can_view_memory(db, current_user, roles, memory):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You are not allowed to view this memory.",
        )
    return _memory_response(memory)


@router.put("/{memory_id}", response_model=MemoryEntryResponse)
def update_memory(
    memory_id: uuid.UUID,
    payload: MemoryEntryUpdate,
    request: Request,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> MemoryEntryResponse:
    memory = _require_memory(db, memory_id)
    roles = get_role_names(db, current_user.id)
    ip_address, device_info = _client_info(request)
    with _translate_memory_errors():
        memory = service.update_memory(
            db,
            memory=memory,
            editor=current_user,
            roles=roles,
            fields=payload.model_dump(exclude_unset=True),
            ip_address=ip_address,
            device_info=device_info,
        )
    return _memory_response(memory)


@router.post("/{memory_id}/media", response_model=MemoryEntryResponse)
async def upload_memory_media(
    memory_id: uuid.UUID,
    request: Request,
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> MemoryEntryResponse:
    """Upload a real image for a memory (creator or admin only).

    Accepts multipart/form-data with an image `file` (jpeg/png/webp, <= 5 MB).
    Sets media_type="image" and media_url to a public local URL.
    """
    memory = _require_memory(db, memory_id)
    roles = get_role_names(db, current_user.id)
    # Access: only the creator or an admin may upload.
    if not service.can_modify_memory(current_user, roles, memory):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You are not allowed to upload media for this memory.",
        )

    # Validate the content type against the image allow-list.
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

    ip_address, device_info = _client_info(request)
    with _translate_memory_errors():
        memory = service.attach_media(
            db,
            memory=memory,
            uploader=current_user,
            roles=roles,
            data=data,
            extension=extension,
            ip_address=ip_address,
            device_info=device_info,
        )
    return _memory_response(memory)


@router.post("/{memory_id}/delete", response_model=MessageResponse)
def delete_memory(
    memory_id: uuid.UUID,
    request: Request,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> MessageResponse:
    memory = _require_memory(db, memory_id)
    roles = get_role_names(db, current_user.id)
    ip_address, device_info = _client_info(request)
    with _translate_memory_errors():
        service.delete_memory(
            db,
            memory=memory,
            editor=current_user,
            roles=roles,
            ip_address=ip_address,
            device_info=device_info,
        )
    return MessageResponse(message="Memory deleted.")
