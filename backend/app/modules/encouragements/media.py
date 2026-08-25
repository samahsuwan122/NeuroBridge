"""Controlled local storage for supportive encouragement media."""

import uuid
from pathlib import Path
from typing import Optional

from app.core.config import get_settings

MEDIA_URL_PREFIX = "/media/encouragement_uploads"

MEDIA_RULES = {
    "image/jpeg": ("image", ".jpg", 5 * 1024 * 1024),
    "image/png": ("image", ".png", 5 * 1024 * 1024),
    "image/webp": ("image", ".webp", 5 * 1024 * 1024),
    "video/mp4": ("video", ".mp4", 50 * 1024 * 1024),
    "video/webm": ("video", ".webm", 50 * 1024 * 1024),
    "video/quicktime": ("video", ".mov", 50 * 1024 * 1024),
    "audio/webm": ("voice", ".webm", 10 * 1024 * 1024),
    "audio/ogg": ("voice", ".ogg", 10 * 1024 * 1024),
    "audio/mp4": ("voice", ".m4a", 10 * 1024 * 1024),
}


def normalize_content_type(content_type: Optional[str]) -> Optional[str]:
    if content_type is None:
        return None
    return content_type.split(";", 1)[0].strip().lower() or None


def media_rule(content_type: Optional[str]) -> Optional[tuple[str, str, int]]:
    normalized = normalize_content_type(content_type)
    return MEDIA_RULES.get(normalized) if normalized else None


def safe_original_filename(filename: Optional[str]) -> bool:
    if not filename or filename in {".", ".."}:
        return False
    if "/" in filename or "\\" in filename or "\x00" in filename:
        return False
    return not any(ord(character) < 32 for character in filename)


def storage_root() -> Path:
    return Path(get_settings().file_storage_path)


def encouragement_uploads_dir() -> Path:
    return storage_root() / "encouragement_uploads"


def public_url(filename: str) -> str:
    return f"{MEDIA_URL_PREFIX}/{filename}"


def save_media_bytes(data: bytes, extension: str) -> str:
    directory = encouragement_uploads_dir()
    directory.mkdir(parents=True, exist_ok=True)
    filename = f"{uuid.uuid4().hex}{extension}"
    (directory / filename).write_bytes(data)
    return filename


def delete_local_media(media_url: Optional[str]) -> None:
    if not media_url or not media_url.startswith(f"{MEDIA_URL_PREFIX}/"):
        return
    filename = media_url[len(MEDIA_URL_PREFIX) + 1 :]
    if not filename or "/" in filename or "\\" in filename or filename in {".", ".."}:
        return
    directory = encouragement_uploads_dir().resolve()
    target = (directory / filename).resolve()
    if directory not in target.parents:
        return
    try:
        target.unlink(missing_ok=True)
    except OSError:
        pass
