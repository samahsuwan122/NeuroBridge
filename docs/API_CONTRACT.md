# API Contract

> **Status: placeholder.** This document is populated starting in **Phase 2 (Backend Skeleton)** and
> grows as each backend phase adds endpoints. No endpoints are implemented in Phase 1.

## Conventions (planned)

- Base path: `/api/v1`
- Format: JSON request/response bodies
- Auth: JWT bearer tokens (introduced in Phase 4)
- Errors: safe, non-revealing error messages; no diagnostic medical language in any response

## Endpoints

_None yet._ The first endpoints will be the health checks added in Phase 2:

| Method | Path | Description | Phase |
|--------|------|-------------|-------|
| GET | `/health` | Service liveness check | 2 |
| GET | `/api/v1/health` | API health check | 2 |

Each subsequent phase (auth, users, patients, games, therapy, AI, reports, etc.) will append its
endpoint definitions here, including request/response schemas and required roles (RBAC).
