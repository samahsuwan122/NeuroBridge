"""Local image storage for provider photo uploads.

Photos are stored under ``<file_storage_path>/provider_photos/`` and served
read-only at ``/media/provider_photos/<filename>`` (see main.py).

DEMO USE: uploaded photos are local demo images only — never real clinicians.

Security notes (mirrors the Memory Album upload rules):
- Only a fixed allow-list of image content types is accepted.
- The stored filename is a fresh UUID + a safe extension derived from the
  content type — the original client filename is never trusted.
- Cleanup only ever deletes files inside the controlled folder whose public URL
  uses the expected prefix.
"""

import uuid
from pathlib import Path
from typing import Optional

from app.core.config import get_settings

# Public URL prefix (also the StaticFiles mount path in main.py).
MEDIA_URL_PREFIX = "/media/provider_photos"

# Allow-list of image content types -> safe file extension.
ALLOWED_CONTENT_TYPES = {
    "image/jpeg": ".jpg",
    "image/png": ".png",
    "image/webp": ".webp",
}

# Maximum accepted upload size (5 MB).
MAX_UPLOAD_BYTES = 5 * 1024 * 1024


def storage_root() -> Path:
    return Path(get_settings().file_storage_path)


def provider_photos_dir() -> Path:
    return storage_root() / "provider_photos"


def extension_for(content_type: Optional[str]) -> Optional[str]:
    if content_type is None:
        return None
    return ALLOWED_CONTENT_TYPES.get(content_type.split(";")[0].strip().lower())


def public_url(filename: str) -> str:
    return f"{MEDIA_URL_PREFIX}/{filename}"


def save_image_bytes(data: bytes, extension: str) -> str:
    directory = provider_photos_dir()
    directory.mkdir(parents=True, exist_ok=True)
    filename = f"{uuid.uuid4().hex}{extension}"
    (directory / filename).write_bytes(data)
    return filename


def delete_local_media(media_url: Optional[str]) -> None:
    """Delete a previously stored local photo, if it is one we control."""
    if not media_url or not media_url.startswith(f"{MEDIA_URL_PREFIX}/"):
        return
    filename = media_url[len(MEDIA_URL_PREFIX) + 1 :]
    if not filename or "/" in filename or "\\" in filename or filename in {".", ".."}:
        return
    directory = provider_photos_dir().resolve()
    target = (directory / filename).resolve()
    if directory not in target.parents:
        return
    try:
        target.unlink(missing_ok=True)
    except OSError:
        pass
