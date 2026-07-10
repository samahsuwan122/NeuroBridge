# NeuroBridge — Project State / Handoff

_Last updated: 2026-07-09_

This file is a handoff/state snapshot so a future session can continue without
losing context. It complements `CLAUDE.md` (rules) and
`PROJECT_EXECUTION_PLAN.md` (roadmap).

## 1. Project name

NeuroBridge — mobile-first, AI-powered cognitive rehabilitation and monitoring
platform. **Not a diagnostic medical system.**

## 2. Current status

- Phase 21B (Attention Focus game) completed and committed locally. Added playable
  `/games/play/attention-focus` — target selection with distractors across 10
  rounds. Results are saved as **game performance only** with metrics
  `exercise_type`, `round_count`, `correct_count`, `mistake_count`,
  `accuracy_percent`. No diagnosis, disease prediction, dementia score, Alzheimer
  score, medical interpretation, or treatment recommendation. **Backend was
  untouched because `attention_focus` was already seeded.** Four exercises are now
  playable: Memory Match, Memory Recall, Reaction Time, Attention Focus.
- Latest local commit: `953d645 feat(mobile): add Attention Focus game`
- Last pushed commit: `cd2029e` — the Phase 15/16/17/18/19/20/21 commits are **not
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
- Phase 20B1: Screen polish — Login, Home, Progress, Profile (styling only)
- Phase 20B2: Screen polish — Games + Memory screens (styling only)
- Phase 21A: Reaction Time playable game (mobile; backend already seeded)
- Phase 21B: Attention Tap playable game (mobile; backend already seeded)

## 4. Demo login (LOCAL DEV ONLY — fake accounts)

- Email: `patient.demo@neurobridge.local`
- Password: `Demo12345!`

(Other demo roles use the same password: `admin.demo@`, `family.demo@`,
`doctor.demo@`, `therapist.demo@` `@neurobridge.local`. Created by
`python -m app.scripts.seed_demo_data`.)

## 5. Current working feature

Phase 21 — More playable games. **Steps 21A (Reaction Time) and 21B (Attention
Focus) are complete and committed.** Backend was **untouched** (`attention_focus`
was already seeded). A new `features/games/attention_tap/` module adds a playable
`/games/play/attention-focus` (wired from game details by slug): each round shows
a grid of icons; tap the target icon (correct tap → +1, any other tap → mistake,
every tap advances). After 10 rounds a correct/mistakes/accuracy/rounds summary;
the result is submitted as **game performance only** (`score` = correct taps,
`metrics: exercise_type/round_count/correct_count/mistake_count/accuracy_percent`)
via the existing games results API. Attention is never interpreted medically.
Deterministic/testable (injectable `Random`, no timers). **Four exercises are now
playable** (Memory Match, Memory Recall, Reaction Time, Attention Focus). **Next
step: Phase 21C — Sequence Recall game.**

## 6. Phase 13 summary (done)

- Progress screen (`/progress`) opened from the Home Progress card.
- Loads saved results from `GET /api/v1/games/results`, joined with
  `GET /api/v1/games` for titles (fallback to id).
- Shows game title, score/max, duration, completed, date, moves/mistakes with
  safe loading/empty/error+retry states. No charts. Game performance only.

## 7. Next step

Phase 21C — Sequence Recall game (the last seeded game, `sequence_order`).
Optional follow-ups also remain: edit/delete/replace UI for memories, or a
progress view per exercise. Also: the Phase 15–21 commits are committed locally
but **not pushed** — push when ready.

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
