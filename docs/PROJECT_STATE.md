# NeuroBridge — Project State / Handoff

_Last updated: 2026-07-09_

This file is a handoff/state snapshot so a future session can continue without
losing context. It complements `CLAUDE.md` (rules) and
`PROJECT_EXECUTION_PLAN.md` (roadmap).

## 1. Project name

NeuroBridge — mobile-first, AI-powered cognitive rehabilitation and monitoring
platform. **Not a diagnostic medical system.**

## 2. Current status

- Phase 18B (mobile image picker + upload) completed and committed locally. From
  the Add Memory form, users can select a JPEG/PNG/WebP image up to 5 MB; the
  form **creates the memory first, then uploads the image** (`POST /memories/{id}
  /media`). If the image upload fails after creation, the memory is kept safely.
  The album list shows an **"Image attached"** chip. Real image preview/display
  is still deferred to Phase 18C.
- Latest local commit: `b810b0a feat(mobile): upload memory images`
- Last pushed commit: `cd2029e` — the Phase 15/16/17/18 commits are **not pushed
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
- Phase 17 (Step 3B): Memory Album mobile create form (POST, no upload)
- Phase 18A: Memory Album backend real image upload (local storage + static URL)
- Phase 18B: Memory Album mobile image picker + upload (create-then-upload)

## 4. Demo login (LOCAL DEV ONLY — fake accounts)

- Email: `patient.demo@neurobridge.local`
- Password: `Demo12345!`

(Other demo roles use the same password: `admin.demo@`, `family.demo@`,
`doctor.demo@`, `therapist.demo@` `@neurobridge.local`. Created by
`python -m app.scripts.seed_demo_data`.)

## 5. Current working feature

Phase 18 — Real Image Upload for Memory Album. **Step 18A (backend) and Step 18B
(mobile image picker + upload) are complete and committed.** The Add Memory form
has a **Choose image** button (`image_picker`, mobile + web) that picks a
JPEG/PNG/WebP up to 5 MB (validated client-side). On save it **creates the memory
then uploads the image** (`POST /memories/{id}/media`); if the image upload fails
after creation the memory is kept and a friendly message is shown. The album list
shows an **"Image attached"** chip for image memories. Images are sent as
in-memory bytes (no local path logged); no edit/delete UI yet. Memories remain
supportive/family-engagement content only — no diagnosis, scoring, or
interpretation. **Real image preview/display is deferred to Phase 18C.**

## 6. Phase 13 summary (done)

- Progress screen (`/progress`) opened from the Home Progress card.
- Loads saved results from `GET /api/v1/games/results`, joined with
  `GET /api/v1/games` for titles (fallback to id).
- Shows game title, score/max, duration, completed, date, moves/mistakes with
  safe loading/empty/error+retry states. No charts. Game performance only.

## 7. Next step

Phase 18C — real image preview/display (show the uploaded image via its
`/media/memory_uploads/<filename>` URL, e.g. on the details screen and/or list).
Edit/delete UI for memories also remains deferred. Final UI polish is deferred
until the core features are complete. Also: the Phase 15/16/17/18 commits are
committed locally but **not pushed** — push when ready.

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
