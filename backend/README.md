# NeuroBridge Backend

The backend is a **FastAPI** (Python) REST API. It serves all clients: the Flutter mobile app
(patient + family) and the React + Vite web dashboard (doctor, therapist, admin, manager).

As of **Phase 9**, this folder contains the FastAPI foundation, the **database foundation**,
**authentication + RBAC**, **admin user management**, the **patient profile module**, and the
**cognitive games module** (game definitions, patient-submitted results, role-scoped result
visibility, audit). There are still **no** assessment, therapy, AI, or report APIs — those come later.

Games are cognitive **exercises** and progress tracking only. There are **no** diagnostic fields;
scores are exercise/game performance only.

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
      0002_patient_profiles.py  # patient_profiles, patient_assignments, patient_family_links
      0003_cognitive_games.py   # game_definitions, game_results
  app/
    __init__.py
    main.py             # FastAPI app + health endpoints
    core/
      __init__.py
      config.py         # environment-driven settings
      database.py       # re-exports engine/session + credential-safe helpers
      security.py       # password hashing (bcrypt)
      permissions.py    # role constants + has_any_role
    db/
      __init__.py
      base.py           # DeclarativeBase + constraint naming convention
      mixins.py         # UUID PK, timestamps, soft-delete mixins
      session.py        # engine + SessionLocal + get_db()
    models/
      __init__.py       # imports all models (registers them on Base.metadata)
      user.py role.py user_role.py medical_center.py audit_log.py
      patient_profile.py patient_assignment.py patient_family_link.py
      game_definition.py game_result.py
    scripts/
      __init__.py
      seed_roles.py     # idempotent seeding of the 6 default roles
      seed_games.py     # idempotent seeding of the default game definitions
    modules/            # feature modules
      __init__.py
      auth/             # authentication + RBAC (Phase 4)
        tokens.py       # JWT create/decode (PyJWT)
        schemas.py service.py routes.py dependencies.py
      audit/            # reusable audit-log service (Phase 4)
        service.py
      admin/            # admin user management (Phase 5)
        schemas.py service.py routes.py
      patients/         # patient profiles + care-team links (Phase 6)
        schemas.py service.py routes.py
      games/            # cognitive games + results (Phase 9)
        schemas.py service.py routes.py
    tests/
      __init__.py
      conftest.py       # isolated in-memory DB + client + user_factory fixtures
      test_health.py    # health endpoint tests
      test_database.py  # model/metadata/seed tests
      test_auth.py      # auth + RBAC tests
      test_admin_users.py  # admin user-management tests
      test_patients.py  # patient profile + visibility tests
      test_games.py     # cognitive games + result visibility tests
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

## Authentication (Phase 4)

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/api/v1/auth/login` | none | Log in with `email_or_phone` + `password`; returns access/refresh tokens, user info, roles |
| GET | `/api/v1/auth/me` | Bearer | Current user's basic info and roles |
| POST | `/api/v1/auth/refresh` | none (refresh token in body) | Issue a new access token from a valid refresh token |
| POST | `/api/v1/auth/logout` | Bearer | Record a logout audit entry (JWT is stateless; client discards the token) |

- **Passwords:** hashed with **bcrypt** (`app/core/security.py`); only the hash is stored. Plain-text
  passwords are never stored or logged.
- **JWT:** **PyJWT** (`app/modules/auth/tokens.py`), signed with `JWT_SECRET_KEY`/`JWT_ALGORITHM`;
  access-token TTL from `JWT_ACCESS_TOKEN_EXPIRE_MINUTES`, refresh from `JWT_REFRESH_TOKEN_EXPIRE_DAYS`.
- **RBAC guards:** `get_current_user`, `get_current_active_user`, and `require_roles([...])` in
  `app/modules/auth/dependencies.py`. Roles are validated against the database.
- **Audit:** successful login writes an `audit_logs` row (`action="login"`); logout writes
  `action="logout"`.
- **Safe errors:** invalid login (unknown user / wrong password / inactive) returns a single generic
  `401`. Missing/invalid bearer token returns `401`; wrong role returns `403`.

> Change `JWT_SECRET_KEY` from the default before any non-local use.

## Admin user management (Phase 5)

All endpoints require an authenticated **admin** (unauthenticated → `401`, non-admin → `403`).
Responses never include `password_hash`.

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/admin/users` | List users (`limit`, `offset`); includes roles |
| POST | `/api/v1/admin/users` | Create a user (hashed password, role assignment) → `201` |
| PUT | `/api/v1/admin/users/{userId}` | Update provided fields; optionally replace roles / reset password |
| POST | `/api/v1/admin/users/{userId}/deactivate` | Set status to `inactive` (no delete) |
| POST | `/api/v1/admin/users/{userId}/activate` | Set status to `active` |
| GET | `/api/v1/admin/roles` | List the seeded roles |

- **Validation:** a user needs at least an email or phone; duplicate email/phone → `409`; unknown
  role → `400`; unknown user → `404`.
- **Audit:** `create_user`, `update_user`, `deactivate_user`, `activate_user` each write an
  `audit_logs` row (with the acting admin as `actor_user_id`).
- There is **no** public registration endpoint — users are provisioned by an admin.

## Patient profiles (Phase 6)

Stores patient profile and care-team relationship data only. **No diagnostic data** — no diagnosis,
disease prediction, or scoring fields.

| Method | Path | Access | Description |
|--------|------|--------|-------------|
| POST | `/api/v1/patients` | admin | Create a patient profile (user must have the `patient` role) |
| GET | `/api/v1/patients` | any (scoped) | List profiles visible to the caller |
| GET | `/api/v1/patients/{id}` | any (scoped) | Get one profile (403 if not visible) |
| PUT | `/api/v1/patients/{id}` | admin | Update provided fields |
| POST | `/api/v1/patients/{id}/assign-clinician` | admin | Assign a doctor/therapist |
| POST | `/api/v1/patients/{id}/link-family` | admin | Link a family/caregiver user |
| POST | `/api/v1/patients/{id}/assignments/{assignment_id}/deactivate` | admin | Deactivate an assignment |
| POST | `/api/v1/patients/{id}/family-links/{link_id}/deactivate` | admin | Deactivate a family link |

- **Visibility (RBAC):** admin → all; manager → same medical center; doctor/therapist → actively
  assigned patients; patient → own profile; family → actively linked profiles. Unauthenticated →
  `401`; authenticated but not permitted → `403`; missing profile → `404`.
- **Validation:** target user must have the `patient` role; one profile per user (duplicate → `409`);
  assigned clinician must hold the matching `doctor`/`therapist` role; linked user must hold the
  `family` role (role mismatch / missing user → `400`).
- **Audit:** `create_patient_profile`, `update_patient_profile`, `assign_clinician`, `link_family`
  (plus `deactivate_assignment` / `deactivate_family_link`).

## Cognitive games (Phase 9)

Cognitive **exercises** and progress tracking — **no diagnosis, disease prediction, or medical
interpretation**. Scores are exercise/game performance only.

| Method | Path | Access | Description |
|--------|------|--------|-------------|
| GET | `/api/v1/games` | any (auth) | List active games (`?include_inactive=true` respected for admin) |
| POST | `/api/v1/games` | admin | Create a game definition (unique slug) |
| GET | `/api/v1/games/results` | any (scoped) | List game results visible to the caller |
| GET | `/api/v1/games/{game_id}` | any (auth) | Get one game definition |
| PUT | `/api/v1/games/{game_id}` | admin | Update a game definition |
| POST | `/api/v1/games/{game_id}/results` | patient | Submit a result for the caller's own profile |

- **Result visibility** reuses the patient-profile rules: admin → all; doctor/therapist → assigned
  patients; patient → own; family → linked; manager → same medical center. Unrelated patients' results
  are never returned.
- **Validation:** duplicate slug → `409`; submit to an inactive game → `400`; submit for a profile you
  don't own → `403`; unknown game → `404`. Seed with `python -m app.scripts.seed_games`
  (memory_match, attention_focus, reaction_time, sequence_order).
- **Audit:** `create_game_definition`, `update_game_definition`, `submit_game_result`.

## Configuration

Backend configuration comes from environment variables (see [`../.env.example`](../.env.example)),
loaded via `app/core/config.py`. Sensible defaults let the app run without a `.env` file. Key values:
`DATABASE_URL` (SQLite locally, PostgreSQL officially), `CORS_ORIGINS`, and `JWT_*` (secret, algorithm,
and token lifetimes used by authentication).

## Safety reminder

NeuroBridge is **not a diagnostic medical system**. No endpoint, response, or generated text may
claim to diagnose any condition. AI output is always a non-diagnostic support recommendation pending
doctor/therapist review. See [`../CLAUDE.md`](../CLAUDE.md).
