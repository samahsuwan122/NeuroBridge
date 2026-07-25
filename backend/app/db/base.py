"""Declarative base and shared metadata for all ORM models.

A constraint naming convention is applied so that primary keys, foreign keys,
unique constraints, and indexes get deterministic names. This keeps Alembic
migrations stable and consistent across SQLite (local dev) and PostgreSQL
(official database).

Note: models are NOT imported here to avoid circular imports. The aggregation
point that imports every model (so they register on `Base.metadata`) is
`app.models` — Alembic's env.py and the tests import that package.
"""

from sqlalchemy import MetaData
from sqlalchemy.orm import DeclarativeBase

# See: https://alembic.sqlalchemy.org/en/latest/naming.html
NAMING_CONVENTION = {
    "ix": "ix_%(column_0_label)s",
    "uq": "uq_%(table_name)s_%(column_0_name)s",
    "ck": "ck_%(table_name)s_%(constraint_name)s",
    "fk": "fk_%(table_name)s_%(column_0_name)s_%(referred_table_name)s",
    "pk": "pk_%(table_name)s",
}


class Base(DeclarativeBase):
    """Base class for all NeuroBridge ORM models."""

    metadata = MetaData(naming_convention=NAMING_CONVENTION)
