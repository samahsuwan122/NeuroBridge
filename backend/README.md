# NeuroBridge Backend

The backend is a **FastAPI** (Python) REST API. It serves all clients: the Flutter mobile app
(patient + family) and the React + Vite web dashboard (doctor, therapist, admin, manager).

As of **Phase 3**, this folder contains a FastAPI application foundation (config + health endpoints)
plus the **database foundation**: SQLAlchemy models, Alembic migrations, and a role seed script.
There is still **no** authentication and **no** business/API modules — those arrive in later phases.

## Python version

- **Target: Python 3.12+** (this project uses 3.12.10).
- The database dependencies (SQLAlchemy/Alembic/psycopg2-binary) ship prebuilt wheels for 3.12, so
  no C/C++ compiler is required. (Python 3.9 is avoided: it lacks a prebuilt `greenlet` wheel and
  fails to build without the MSVC C++ Build Tools.)

## Structure

```text
backend/
  README.md
  requirements.txt
  alembic.ini           # Alembic config (DB URL injected from settings; no creds here)
  alembic/
    env.py              # migration environment (reads DATABASE_URL from settings)
    script.py.mako
    versions/
      0001_initial.py   # creates users, roles, user_roles, medical_centers, audit_logs
  app/
    __init__.py
    main.py             # FastAPI app + health endpoints
    core/
      __init__.py
      config.py         # environment-driven settings
      database.py       # re-exports engine/session + credential-safe helpers
    db/
      __init__.py
      base.py           # DeclarativeBase + constraint naming convention
      mixins.py         # UUID PK, timestamps, soft-delete mixins
      session.py        # engine + SessionLocal + get_db()
    models/
      __init__.py       # imports all models (registers them on Base.metadata)
      user.py role.py user_role.py medical_center.py audit_log.py
    scripts/
      __init__.py
      seed_roles.py     # idempotent seeding of the 6 default roles
    modules/            # feature modules (later phases)
      __init__.py
    tests/
      __init__.py
      test_health.py    # health endpoint tests
      test_database.py  # model/metadata/seed tests
```

## Database

- **Local dev:** SQLite (`sqlite:///./neurobridge_dev.db`), created by running the migration. The
  `*.db` file is git-ignored.
- **Official database:** PostgreSQL — set `DATABASE_URL` to a `postgresql://...` URL. Models use a
  portable UUID type (native UUID on PostgreSQL, CHAR on SQLite) and portable JSON.
- **Migrations:** Alembic. The DB URL is injected from settings in `alembic/env.py`, so no
  credentials live in `alembic.ini`.
- **Models (Phase 3):** `users`, `roles`, `user_roles`, `medical_centers`, `audit_logs`. The
  `users` ⇄ `medical_centers` circular FK is handled with a batch ALTER that works on both SQLite
  and PostgreSQL.

## Commands

Run these from the `backend/` folder.

```bash
# 1. Create and activate a virtual environment
py -m venv .venv
# Windows:  .venv\Scripts\activate
# Unix:     source .venv/bin/activate

# 2. Install dependencies
python -m pip install -r requirements.txt

# 3. Apply database migrations (creates the SQLite dev DB by default)
python -m alembic upgrade head

# 4. Seed the six default roles (idempotent)
python -m app.scripts.seed_roles

# 5. Run the development server
uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
#    Health checks:
#      http://127.0.0.1:8000/health
#      http://127.0.0.1:8000/api/v1/health
#    Interactive docs:  http://127.0.0.1:8000/docs

# 6. Run tests
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
