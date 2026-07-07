# NeuroBridge Backend

The backend is a **FastAPI** (Python) REST API. It serves all clients: the Flutter mobile app
(patient + family) and the React + Vite web dashboard (doctor, therapist, admin, manager).

In Phase 1 this folder is **foundation only** — package structure and this README. No application
logic, routes, models, or auth exist yet.

## Python version

- **Recommended: Python 3.11+.**
- This machine currently has **Python 3.9** available through the `py` launcher. Python 3.9 is enough
  to scaffold, but **upgrading to 3.11+ is recommended before deeper backend work** (Phase 2 onward)
  to match modern FastAPI/typing features and avoid compatibility surprises.

## Planned structure

```text
backend/
  README.md
  requirements.txt
  app/
    __init__.py
    main.py            # FastAPI app entry point (activated in Phase 2)
    core/              # config, security, database, permissions (later phases)
      __init__.py
    modules/           # feature modules: auth, users, patients, ... (later phases)
      __init__.py
    tests/             # test suite (activated in Phase 2)
      __init__.py
```

## Commands — **to be activated in Phase 2**

> These commands are documented for reference. The app entry point and dependencies are wired up in
> **Phase 2 (Backend Skeleton)**; they are not runnable yet in Phase 1.

```bash
# 1. Create and activate a virtual environment (run inside backend/)
py -m venv .venv
# Windows:  .venv\Scripts\activate
# Unix:     source .venv/bin/activate

# 2. Install dependencies
pip install -r requirements.txt

# 3. Run the development server  (Phase 2+)
uvicorn app.main:app --reload --host 127.0.0.1 --port 8000

# 4. Run tests  (Phase 2+)
pytest
```

## Configuration

Backend configuration comes from environment variables (see [`../.env.example`](../.env.example)).
Key values: `DATABASE_URL` (SQLite locally, PostgreSQL officially), `JWT_*` settings, and
`CORS_ORIGINS`.

## Safety reminder

NeuroBridge is **not a diagnostic medical system**. No endpoint, response, or generated text may
claim to diagnose any condition. AI output is always a non-diagnostic support recommendation pending
doctor/therapist review. See [`../CLAUDE.md`](../CLAUDE.md).
