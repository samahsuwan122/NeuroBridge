"""Application configuration for the NeuroBridge backend.

Settings are loaded from environment variables (and an optional project-root
`.env` file). Sensible defaults are provided so the app can run for local
development and tests even without a `.env` file.

Phase 2 scope: configuration only. No auth, no models, no business logic.
"""

from functools import lru_cache
from pathlib import Path
from typing import List, Optional

from pydantic_settings import BaseSettings, SettingsConfigDict

# Project root is four levels up from this file:
#   backend/app/core/config.py -> backend/app/core -> backend/app -> backend -> <root>
PROJECT_ROOT = Path(__file__).resolve().parents[3]
ENV_FILE = PROJECT_ROOT / ".env"


class Settings(BaseSettings):
    """Environment-driven application settings."""

    model_config = SettingsConfigDict(
        env_file=str(ENV_FILE),
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    # --- Application ---
    app_name: str = "NeuroBridge"
    app_env: str = "development"
    app_debug: bool = True

    # --- Server ---
    backend_host: str = "127.0.0.1"
    backend_port: int = 8000

    # --- Database (placeholder in Phase 2; models/migrations arrive in Phase 3) ---
    # Local development defaults to SQLite; PostgreSQL is the official database.
    database_url: str = "sqlite:///./neurobridge_dev.db"
    postgres_database_url: Optional[str] = None

    # --- JWT (defined here for later phases; no auth logic implemented yet) ---
    jwt_secret_key: str = "change_me"
    jwt_algorithm: str = "HS256"
    jwt_access_token_expire_minutes: int = 30
    jwt_refresh_token_expire_days: int = 7

    # --- CORS ---
    # Kept as a raw string so values like "[http://localhost:5173,http://localhost:3000]"
    # parse reliably. Use `cors_origins_list` to get the parsed list.
    cors_origins: str = "http://localhost:5173,http://localhost:3000"

    # --- Notifications / email (placeholders for later phases) ---
    fcm_server_key: Optional[str] = None
    email_host: Optional[str] = None
    email_port: Optional[str] = None
    email_user: Optional[str] = None
    email_password: Optional[str] = None

    # --- Files / AI mode ---
    file_storage_path: str = "./storage"
    ai_mode: str = "rule_based"

    @property
    def cors_origins_list(self) -> List[str]:
        """Parse CORS_ORIGINS into a clean list of origins.

        Accepts either "a,b" or "[a,b]" formats and ignores surrounding
        brackets, quotes, and whitespace.
        """
        raw = self.cors_origins.strip().strip("[]")
        return [origin.strip().strip("\"'") for origin in raw.split(",") if origin.strip()]


@lru_cache
def get_settings() -> Settings:
    """Return a cached Settings instance."""
    return Settings()
