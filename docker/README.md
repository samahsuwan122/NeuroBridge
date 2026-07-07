# Docker / Deployment

> **Docker is not installed on the current development machine**, and no container files exist yet.

Local development does **not** require Docker: the backend runs directly with `uvicorn` and uses
**SQLite** by default (see [`../.env.example`](../.env.example)).

## Planned (later phase)

Docker support will be added later to make it easy to run **PostgreSQL** (the official database) and
the **FastAPI backend** in containers, for example via a `docker-compose.yml` in this folder:

- A `postgres` service for the official database.
- A `backend` service for the FastAPI API.
- Environment configuration wired from `.env`.

This is introduced around the deployment-preparation phase in
[`../PROJECT_EXECUTION_PLAN.md`](../PROJECT_EXECUTION_PLAN.md). No secrets will be committed.
