"""Core backend building blocks.

Phase 2 introduces configuration (`config.py`) and a database connection
placeholder (`database.py`). Security and RBAC/permission helpers are added in
later phases.
"""

from app.core.config import Settings, get_settings

__all__ = ["Settings", "get_settings"]
