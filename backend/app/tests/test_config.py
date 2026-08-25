"""Security-sensitive application configuration tests."""

import pytest
from pydantic import ValidationError

from app.core.config import Settings


def test_jwt_secret_is_required(monkeypatch):
    monkeypatch.delenv("JWT_SECRET_KEY", raising=False)

    with pytest.raises(ValidationError, match="jwt_secret_key"):
        Settings(_env_file=None)


def test_jwt_secret_rejects_fewer_than_32_bytes():
    with pytest.raises(ValidationError, match="at least 32 bytes"):
        Settings(jwt_secret_key="short-key", _env_file=None)


def test_jwt_secret_accepts_at_least_32_utf8_bytes():
    settings = Settings(jwt_secret_key="é" * 16, _env_file=None)

    assert len(settings.jwt_secret_key.encode("utf-8")) == 32
