"""Family encouragement routes.

- Listing: any authenticated active user, scoped by role (admin=all,
  doctor/therapist=assigned, patient=own, family=linked, manager=same center).
- Creating: a linked family member or an admin only.

MEDICAL SAFETY: family support content only — supportive messages, never medical
advice, diagnosis, or assessment.
"""

import uuid
from contextlib import contextmanager
from typing import Optional

from fastapi import (
    APIRouter,
    Depends,
    File,
    Form,
    HTTPException,
    Query,
    Request,
    UploadFile,
    status,
)
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models import User
from app.modules.auth.dependencies import get_current_active_user
from app.modules.auth.service import get_role_names
from app.modules.encouragements import media, service
from app.modules.encouragements.schemas import (
    EncouragementCreate,
    EncouragementListResponse,
    EncouragementResponse,
)

router = APIRouter(prefix="/api/v1/encouragements", tags=["encouragements"])


@contextmanager
def _translate_errors():
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


@router.get("", response_model=EncouragementListResponse)
def list_encouragements(
    patient_profile_id: Optional[uuid.UUID] = Query(default=None),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> EncouragementListResponse:
    roles = get_role_names(db, current_user.id)
    items, total = service.list_encouragements(
        db,
        current_user,
        roles,
        patient_profile_id=patient_profile_id,
        limit=limit,
        offset=offset,
    )
    return EncouragementListResponse(
        total=total,
        limit=limit,
        offset=offset,
        encouragements=[EncouragementResponse.model_validate(i) for i in items],
    )


@router.post(
    "",
    response_model=EncouragementResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_encouragement(
    payload: EncouragementCreate,
    request: Request,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> EncouragementResponse:
    roles = get_role_names(db, current_user.id)
    ip_address, device_info = _client_info(request)
    with _translate_errors():
        encouragement = service.create_encouragement(
            db,
            sender=current_user,
            roles=roles,
            patient_profile_id=payload.patient_profile_id,
            message=payload.message,
            ip_address=ip_address,
            device_info=device_info,
        )
    return EncouragementResponse.model_validate(encouragement)


@router.post(
    "/media",
    response_model=EncouragementResponse,
    status_code=status.HTTP_201_CREATED,
)
async def create_media_encouragement(
    request: Request,
    patient_profile_id: uuid.UUID = Form(...),
    message: Optional[str] = Form(default=None, max_length=300),
    caption: Optional[str] = Form(default=None, max_length=180),
    media_duration_seconds: Optional[int] = Form(default=None, ge=0),
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> EncouragementResponse:
    form = await request.form()
    allowed_fields = {
        "patient_profile_id",
        "message",
        "caption",
        "media_duration_seconds",
        "file",
    }
    if any(key not in allowed_fields for key in form.keys()):
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
            detail="Unsupported multipart field.",
        )

    clean_message = message.strip() if message is not None else None
    clean_caption = caption.strip() if caption is not None else None
    if message is not None and not clean_message:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
            detail="message must not be empty when supplied.",
        )
    if caption is not None and not clean_caption:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
            detail="caption must not be empty when supplied.",
        )
    if not media.safe_original_filename(file.filename):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Unsafe upload filename.",
        )

    mime_type = media.normalize_content_type(file.content_type)
    rule = media.media_rule(mime_type)
    if rule is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Unsupported encouragement media type.",
        )
    media_type, extension, maximum_bytes = rule
    data = await file.read(maximum_bytes + 1)
    if not data:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="The file is empty."
        )
    if len(data) > maximum_bytes:
        raise HTTPException(
            status_code=status.HTTP_413_CONTENT_TOO_LARGE,
            detail="The media file is too large.",
        )

    filename = media.save_media_bytes(data, extension)
    media_url = media.public_url(filename)
    roles = get_role_names(db, current_user.id)
    ip_address, device_info = _client_info(request)
    try:
        with _translate_errors():
            encouragement = service.create_encouragement(
                db,
                sender=current_user,
                roles=roles,
                patient_profile_id=patient_profile_id,
                message=clean_message,
                caption=clean_caption,
                media_type=media_type,
                media_url=media_url,
                media_mime_type=mime_type,
                media_size_bytes=len(data),
                media_duration_seconds=media_duration_seconds,
                ip_address=ip_address,
                device_info=device_info,
            )
    except Exception:
        db.rollback()
        media.delete_local_media(media_url)
        raise
    return EncouragementResponse.model_validate(encouragement)
