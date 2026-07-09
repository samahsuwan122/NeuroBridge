# NeuroBridge — Project State / Handoff

_Last updated: 2026-07-09_

This file is a handoff/state snapshot so a future session can continue without
losing context. It complements `CLAUDE.md` (rules) and
`PROJECT_EXECUTION_PLAN.md` (roadmap).

## 1. Project name

NeuroBridge — mobile-first, AI-powered cognitive rehabilitation and monitoring
platform. **Not a diagnostic medical system.**

## 2. Current status

- Phase 17 Step 3A (Memory Album mobile viewing) completed and committed
  locally. Adds read-only Memory Album list + detail screens (`/memories`,
  `/memories/details`) on top of the Step 2 backend. Create/edit/delete and real
  image upload are still deferred to later steps/phases.
- Latest local commit: `0bcd6dd feat(mobile): add memory album viewing`
- Last pushed commit: `cd2029e` — the Phase 15/16/17 commits are **not pushed
  yet** (`origin/main` is behind local `main`).
- Working tree is clean (after this docs commit).

## 3. Completed phases summary

- Phase 1: project foundation
- Phase 2: FastAPI backend skeleton
- Phase 3: database foundation
- Phase 4: auth and RBAC
- Phase 5: admin user management
- Phase 6: patient profiles and relationships
- Phase 7: Flutter foundation with login
- Phase 8: patient home dashboard
- Phase 9: cognitive games backend
- Phase 10: mobile games list/details
- Phase 11: playable Memory Match game
- Phase 12: Memory Match result submission to backend
- Phase 13: patient progress screen (mobile) — lists saved game results
- Phase 14: read-only patient profile screen (mobile)
- Phase 15: patient care & safety information (backend + mobile)
- Phase 16: premium medical mobile theme (styling only)
- Phase 17 (Step 2): Memory Album backend foundation (model, migration, APIs)
- Phase 17 (Step 3A): Memory Album mobile viewing (read-only list + detail)

## 4. Demo login (LOCAL DEV ONLY — fake accounts)

- Email: `patient.demo@neurobridge.local`
- Password: `Demo12345!`

(Other demo roles use the same password: `admin.demo@`, `family.demo@`,
`doctor.demo@`, `therapist.demo@` `@neurobridge.local`. Created by
`python -m app.scripts.seed_demo_data`.)

## 5. Current working feature

Phase 17 — Memory Album. **Step 2 (backend) and Step 3A (mobile viewing) are
complete and committed.** Step 3A added a read-only Memory Album — a new
`memories` feature (model/API/controller) with a **list screen** (`/memories`)
and a **detail screen** (`/memories/details`), reached from a new Home "Memory
Album" card, loading from `GET /api/v1/memories` with safe loading/empty/error+
retry states. View-only: no create/edit/delete UI and no real image upload
(`media_url` shown as placeholder text). Memories are supportive/family-
engagement content only — no diagnosis, scoring, or medical interpretation.
**Next step: Phase 17 Step 3B — the Add Memory form** (family create via
`POST /api/v1/memories`); real image upload remains deferred to a later phase.

## 6. Phase 13 summary (done)

- Progress screen (`/progress`) opened from the Home Progress card.
- Loads saved results from `GET /api/v1/games/results`, joined with
  `GET /api/v1/games` for titles (fallback to id).
- Shows game title, score/max, duration, completed, date, moves/mistakes with
  safe loading/empty/error+retry states. No charts. Game performance only.

## 7. Next step

Phase 17 Step 3B — the mobile **Add Memory form** (family create via
`POST /api/v1/memories`). Real image upload is deferred to a later phase. Final
UI polish is also deferred until the core features are complete. Also: the Phase
15/16/17 commits are committed locally but **not pushed** — push when ready.

## 8. Medical safety rules

- No diagnosis.
- No disease prediction.
- No dementia score.
- No Alzheimer score.
- No medical interpretation.
- Results are game/exercise performance only.

## 9. Run commands

Backend:

```powershell
cd backend
.\.venv\Scripts\activate
python -m alembic upgrade head
python -m app.scripts.seed_demo_data
uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

Mobile:

```powershell
cd mobile
flutter run -d chrome --web-port=3000
```

(Use `--web-port=3000` so the browser origin matches the backend CORS allowlist.)

## 10. Testing commands

Backend:

```powershell
python -m pytest -q
```

Mobile:

```powershell
flutter pub get
flutter analyze
flutter test
flutter build web
```
