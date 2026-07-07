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

No cognitive games, therapy, AI, or reports APIs are implemented yet.
NeuroBridge is NOT a diagnostic medical system.
"""

import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core import database
from app.core.config import get_settings
from app.modules.admin.routes import router as admin_router
from app.modules.auth.routes import router as auth_router
from app.modules.patients.routes import router as patients_router

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
