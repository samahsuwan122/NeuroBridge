"""Database package for the NeuroBridge backend (Phase 3).

Contains the declarative base, reusable mixins, and the engine/session setup.
Models live in `app.models`.
"""

from app.db.base import Base

__all__ = ["Base"]
