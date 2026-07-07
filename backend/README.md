# NeuroBridge Backend

The backend is a **FastAPI** (Python) REST API. It serves all clients: the Flutter mobile app
(patient + family) and the React + Vite web dashboard (doctor, therapist, admin, manager).

As of **Phase 2**, this folder contains a real FastAPI application foundation: environment-driven
config, a database-connection placeholder, and health endpoints. There is still **no** authentication,
no database models, and no business modules — those arrive in later phases.

## Python version

- **Recommended: Python 3.11+.**
- This machine currently has **Python 3.9** available through the `py` launcher. Python 3.9 is enough
  to scaffold, but **upgrading to 3.11+ is recommended before deeper backend work** (Phase 2 onward)
  to match modern FastAPI/typing features and avoid compatibility surprises.

## Structure

```text
backend/
  README.md
  requirements.txt
  app/
    __init__.py
    main.py            # FastAPI app + health endpoints (Phase 2)
    core/              # cross-cutting concerns
      __init__.py
      config.py        # environment-driven settings (Phase 2)
      database.py      # DATABASE_URL placeholder — no SQLAlchemy/models yet (Phase 2)
    modules/           # feature modules: auth, users, patients, ... (later phases)
      __init__.py
    tests/             # test suite
      __init__.py
      test_health.py   # health endpoint tests (Phase 2)
```

## Commands

Run these from the `backend/` folder.

```bash
# 1. Create and activate a virtual environment
py -m venv .venv
# Windows:  .venv\Scripts\activate
# Unix:     source .venv/bin/activate

# 2. Install dependencies
python -m pip install -r requirements.txt

# 3. Run the development server
uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
#    Health checks:
#      http://127.0.0.1:8000/health
#      http://127.0.0.1:8000/api/v1/health
#    Interactive docs:  http://127.0.0.1:8000/docs

# 4. Run tests
pytest
```

## Endpoints (Phase 2)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Service liveness check |
| GET | `/api/v1/health` | Versioned API health check |

Both return: `success`, `service` (`"NeuroBridge API"`), `status` (`"healthy"`), `version` (`"v1"`),
and `environment` (current `APP_ENV`).

## Configuration

Backend configuration comes from environment variables (see [`../.env.example`](../.env.example)),
loaded via `app/core/config.py`. Sensible defaults let the app run without a `.env` file. Key values:
`DATABASE_URL` (SQLite locally, PostgreSQL officially), `CORS_ORIGINS`, and `JWT_*` (reserved for the
auth phase; no auth logic exists yet).

## Safety reminder

NeuroBridge is **not a diagnostic medical system**. No endpoint, response, or generated text may
claim to diagnose any condition. AI output is always a non-diagnostic support recommendation pending
doctor/therapist review. See [`../CLAUDE.md`](../CLAUDE.md).
