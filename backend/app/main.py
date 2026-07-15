"""NeuroBridge backend application entry point.

Phase 2 — Backend Skeleton.

This defines a real FastAPI application with:
- App title "NeuroBridge API" and API version "v1"
- Environment-driven configuration
- CORS configured from CORS_ORIGINS
- Health endpoints: GET /health and GET /api/v1/health
- Authentication routes under /api/v1/auth (Phase 4)
- Admin user-management routes under /api/v1/admin (Phase 5)
- Patient profile routes under /api/v1/patients (Phase 6)
- Cognitive games routes under /api/v1/games (Phase 9)
- Memory Album routes under /api/v1/memories (Phase 17)
- Uploaded Memory Album images served read-only under /media/memory_uploads (Phase 18)

No therapy, AI, or reports APIs are implemented yet.
NeuroBridge is NOT a diagnostic medical system.
"""

import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.core import database
from app.core.config import get_settings
from app.modules.admin.routes import router as admin_router
from app.modules.appointments.routes import router as appointments_router
from app.modules.auth.routes import router as auth_router
from app.modules.encouragements.routes import router as encouragements_router
from app.modules.games.routes import router as games_router
from app.modules.memories.media import MEDIA_URL_PREFIX, memory_uploads_dir
from app.modules.memories.routes import router as memories_router
from app.modules.messages.routes import router as provider_messages_router
from app.modules.patients.routes import router as patients_router
from app.modules.providers.media import (
    MEDIA_URL_PREFIX as PROVIDER_MEDIA_URL_PREFIX,
    provider_photos_dir,
)
from app.modules.providers.routes import router as providers_router

logger = logging.getLogger("neurobridge")

settings = get_settings()

API_VERSION = "v1"
SERVICE_NAME = "NeuroBridge API"


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application startup/shutdown logging (no side effects on the database)."""
    logger.info("%s starting (environment=%s)", SERVICE_NAME, settings.app_env)
    logger.info(
        "Database configured: backend=%s", database.describe_configured_database()
    )
    yield
    logger.info("%s shutting down", SERVICE_NAME)


app = FastAPI(
    title=SERVICE_NAME,
    version=API_VERSION,
    lifespan=lifespan,
)

# CORS — allow the configured web dashboard origins.
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Feature routers.
app.include_router(auth_router)
app.include_router(admin_router)
app.include_router(patients_router)
app.include_router(games_router)
app.include_router(memories_router)
app.include_router(encouragements_router)
app.include_router(appointments_router)
app.include_router(providers_router)
app.include_router(provider_messages_router)

# Serve uploaded Memory Album images read-only. The directory is created if
# missing so the mount is always valid; its contents are runtime-only and
# git-ignored (never committed).
_memory_media_dir = memory_uploads_dir()
_memory_media_dir.mkdir(parents=True, exist_ok=True)
app.mount(
    MEDIA_URL_PREFIX,
    StaticFiles(directory=str(_memory_media_dir)),
    name="memory_media",
)

# Serve uploaded provider photos read-only (demo images only; git-ignored).
_provider_photos_dir = provider_photos_dir()
_provider_photos_dir.mkdir(parents=True, exist_ok=True)
app.mount(
    PROVIDER_MEDIA_URL_PREFIX,
    StaticFiles(directory=str(_provider_photos_dir)),
    name="provider_media",
)


def _health_payload() -> dict:
    """Shared health-check response body."""
    return {
        "success": True,
        "service": SERVICE_NAME,
        "status": "healthy",
        "version": API_VERSION,
        "environment": settings.app_env,
    }


@app.get("/health", tags=["health"])
def health() -> dict:
    """Service liveness check."""
    return _health_payload()


@app.get("/api/v1/health", tags=["health"])
def api_health() -> dict:
    """Versioned API health check."""
    return _health_payload()
