# NeuroBridge — Project State / Handoff

_Last updated: 2026-07-09_

This file is a handoff/state snapshot so a future session can continue without
losing context. It complements `CLAUDE.md` (rules) and
`PROJECT_EXECUTION_PLAN.md` (roadmap).

## 1. Project name

NeuroBridge — mobile-first, AI-powered cognitive rehabilitation and monitoring
platform. **Not a diagnostic medical system.**

## 2. Current status

- Phase 20A (final luxury UI polish foundation) completed and committed locally.
  The shared `LoadingState` and `ErrorState` were refined, and Home, Game
  Details, Memory Album, and Memory Recall received light premium polish. **No
  API, navigation, game-result, or business logic changes** were made; the
  backend was untouched.
- Latest local commit: `4618f83 style(mobile): polish premium medical UI`
- Last pushed commit: `cd2029e` — the Phase 15/16/17/18/19/20 commits are **not
  pushed yet** (`origin/main` is behind local `main`).
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
- Phase 18C: Memory Album image display (thumbnails + detail hero + placeholders)
- Phase 19A: Memory Recall cognitive game backend foundation (idempotent seed)
- Phase 19B: Memory Recall mobile game (personalized, Memory Album questions)
- Phase 20A: Final luxury UI polish foundation (shared states + light screen polish)

## 4. Demo login (LOCAL DEV ONLY — fake accounts)

- Email: `patient.demo@neurobridge.local`
- Password: `Demo12345!`

(Other demo roles use the same password: `admin.demo@`, `family.demo@`,
`doctor.demo@`, `therapist.demo@` `@neurobridge.local`. Created by
`python -m app.scripts.seed_demo_data`.)

## 5. Current working feature

Phase 20 — Final Luxury UI Polish. **Step 20A (foundation + light polish) is
complete and committed.** Styling/layout only — no behavior, navigation, API, or
game-result changes; no new foundation files (the existing `core/theme` +
`EmeraldPanel`/`IconChip`/`SectionHeader` were reused). The shared
`LoadingState`/`ErrorState` are now centered and elegant (tinted icon + clear
retry) so every screen's loading/empty/error states are consistent; Home gained
an "Activities" section header; Game details groups metadata/instructions in a
card; the Memory Album empty state is a friendly icon + message; and the Memory
Recall summary uses an emerald gradient header. Wording stays supportive and
performance-only. **Next step: Phase 20B — Final Screen-by-Screen Polish.**

## 6. Phase 13 summary (done)

- Progress screen (`/progress`) opened from the Home Progress card.
- Loads saved results from `GET /api/v1/games/results`, joined with
  `GET /api/v1/games` for titles (fallback to id).
- Shows game title, score/max, duration, completed, date, moves/mistakes with
  safe loading/empty/error+retry states. No charts. Game performance only.

## 7. Next step

Phase 20B — Final Screen-by-Screen Polish (continue the light premium refinement
across the remaining screens). Optional follow-ups also remain: edit/delete/
replace UI for memories, or a progress view for Memory Recall results. Also: the
Phase 15/16/17/18/19/20 commits are committed locally but **not pushed** — push
when ready.

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
