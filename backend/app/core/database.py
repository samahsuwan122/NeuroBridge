"""Database connection placeholder for the NeuroBridge backend.

Phase 2 scope: read `DATABASE_URL` only.

- No SQLAlchemy engine, ORM models, or sessions are created here.
- No migrations are run here.
- The real engine/session setup and models arrive in **Phase 3**, together with
  SQLAlchemy and Alembic.

Local development uses SQLite by default; PostgreSQL is the official database.
The active database is chosen entirely by the `DATABASE_URL` value.
"""

from urllib.parse import urlparse

from app.core.config import get_settings


def get_database_url() -> str:
    """Return the configured database URL from settings."""
    return get_settings().database_url


def describe_configured_database() -> str:
    """Return the configured database backend name only (no credentials).

    Examples: "sqlite", "postgresql". For a URL like
    "postgresql+psycopg2://..." the base backend ("postgresql") is returned.
    """
    scheme = urlparse(get_database_url()).scheme or "unknown"
    return scheme.split("+", 1)[0]
