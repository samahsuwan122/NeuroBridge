"""Local image storage for Memory Album uploads.

Images are stored on the local filesystem under
``<file_storage_path>/memory_uploads/`` and served read-only at
``/media/memory_uploads/<filename>`` (see main.py).

MEDICAL SAFETY: images are supportive/family-engagement content only. They are
never analyzed, scored, or interpreted.

Security notes:
- Only a fixed allow-list of image content types is accepted.
- The stored filename is a fresh UUID + a safe extension derived from the
  content type — the original client filename is never trusted.
- Cleanup only ever deletes files that live *inside* the controlled upload
  folder and whose public URL uses the expected prefix.
"""

import uuid
from pathlib import Path
from typing import Optional

from app.core.config import get_settings

# Public URL prefix (also the StaticFiles mount path in main.py).
MEDIA_URL_PREFIX = "/media/memory_uploads"

# Allow-list of image content types -> safe file extension.
ALLOWED_CONTENT_TYPES = {
    "image/jpeg": ".jpg",
    "image/png": ".png",
    "image/webp": ".webp",
}

# Maximum accepted upload size (5 MB).
MAX_UPLOAD_BYTES = 5 * 1024 * 1024


def storage_root() -> Path:
    """Root storage directory (from settings; monkeypatched in tests)."""
    return Path(get_settings().file_storage_path)


def memory_uploads_dir() -> Path:
    """Directory where Memory Album images are stored."""
    return storage_root() / "memory_uploads"


def extension_for(content_type: Optional[str]) -> Optional[str]:
    """Safe extension for an allowed image content type, else None."""
    if content_type is None:
        return None
    return ALLOWED_CONTENT_TYPES.get(content_type.split(";")[0].strip().lower())


def public_url(filename: str) -> str:
    """Public relative URL for a stored file."""
    return f"{MEDIA_URL_PREFIX}/{filename}"


def save_image_bytes(data: bytes, extension: str) -> str:
    """Write image bytes under a fresh UUID name; return the stored filename."""
    directory = memory_uploads_dir()
    directory.mkdir(parents=True, exist_ok=True)
    filename = f"{uuid.uuid4().hex}{extension}"
    (directory / filename).write_bytes(data)
    return filename


def delete_local_media(media_url: Optional[str]) -> None:
    """Delete a previously stored local image, if it is one we control.

    Only deletes when the URL uses our prefix AND the resolved path is inside the
    upload folder. External URLs or unexpected/unsafe paths are left untouched.
    """
    if not media_url or not media_url.startswith(f"{MEDIA_URL_PREFIX}/"):
        return
    filename = media_url[len(MEDIA_URL_PREFIX) + 1 :]
    # Reject anything that is not a bare filename (no traversal / subpaths).
    if not filename or "/" in filename or "\\" in filename or filename in {".", ".."}:
        return
    directory = memory_uploads_dir().resolve()
    target = (directory / filename).resolve()
    # Ensure the resolved target is still inside the controlled folder.
    if directory not in target.parents:
        return
    try:
        target.unlink(missing_ok=True)
    except OSError:
        # Never fail the request because an old file could not be removed.
        pass
