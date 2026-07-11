# NeuroBridge — Project State / Handoff

_Last updated: 2026-07-09_

This file is a handoff/state snapshot so a future session can continue without
losing context. It complements `CLAUDE.md` (rules) and
`PROJECT_EXECUTION_PLAN.md` (roadmap).

## 1. Project name

NeuroBridge — mobile-first, AI-powered cognitive rehabilitation and monitoring
platform. **Not a diagnostic medical system.**

## 2. Current status

- Phase 24A (Final Design Upgrade) completed and committed locally. Refined the
  shared **premium theme foundation**: improved cards, primary buttons, heading
  rhythm, and `EmeraldPanel` styling. The polish **propagates across Login, Home,
  Games, Memory Album, Progress, Profile, and all game screens**. **No backend,
  API, business logic, auth logic, localization logic, game mechanics, or
  result-saving changes**; RTL/LTR and 10-language support remain safe. The
  `frontend-design` skill files remain **local and ignored by Git**.
- Latest local commit: `99c7c78 style(mobile): refine premium design foundation`
- Last pushed commit: `cd2029e` — the Phase 15–24 commits are **not pushed yet**
  (`origin/main` is behind local `main`).
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
- Phase 21C: Sequence Recall playable game (mobile; backend already seeded)
- Phase 22A: Progress analytics dashboard (mobile; performance summaries only)
- Phase 23A: Global 10-language support (mobile; ar RTL + 9 LTR, English fallback)
- Phase 24A: Final design upgrade (mobile; shared theme + EmeraldPanel polish)

## 4. Demo login (LOCAL DEV ONLY — fake accounts)

- Email: `patient.demo@neurobridge.local`
- Password: `Demo12345!`

(Other demo roles use the same password: `admin.demo@`, `family.demo@`,
`doctor.demo@`, `therapist.demo@` `@neurobridge.local`. Created by
`python -m app.scripts.seed_demo_data`.)

## 5. Current working feature

None in progress. **Phase 24A — Final Design Upgrade is complete and committed.**
Mobile-only styling of the shared theme foundation (`core/theme/app_theme.dart`,
`core/widgets/emerald_panel.dart`): cards now have a crisp hairline edge + softer
deeper shadow, primary emerald buttons get a subtle lift, heading rhythm is
tightened via line-height (no `letterSpacing`, to protect Arabic/Devanagari
shaping), and the `EmeraldPanel` hero gains a thin champagne-gold hairline frame.
Because these are shared pieces, the polish propagates to **all 13 high-impact
screens** at once. **No behavior/API/logic/localization changes**; RTL/LTR and
the 10 languages remain safe. The `frontend-design` skill guidance was applied
from its local `SKILL.md` (the skill is Git-ignored). **Next step: final demo
review and graduation presentation preparation.**

## 5b. Previous feature

Phase 22 — Progress Analytics. **Step 22A (dashboard) is complete and committed.**
Mobile-only, **no backend/API/result-logic changes** (analytics are pure
client-side computations over existing results). The Progress screen is now a
premium **performance analytics dashboard**: `ProgressAnalytics.from(results)`
derives total exercises, completed count, best and average score %, latest
activity, and a per-game breakdown; the UI shows summary cards, a Game breakdown
section, and a Recent activity list. Everything is **performance-only** — no
diagnosis, cognitive level, or normal/abnormal wording. Loading/empty/error
states unchanged. **Next step: Phase 22B — Family / Doctor Progress Review.**

## 6. Phase 13 summary (done)

- Progress screen (`/progress`) opened from the Home Progress card.
- Loads saved results from `GET /api/v1/games/results`, joined with
  `GET /api/v1/games` for titles (fallback to id).
- Shows game title, score/max, duration, completed, date, moves/mistakes with
  safe loading/empty/error+retry states. No charts. Game performance only.

## 7. Next step

Final demo review and graduation presentation preparation — the app is
feature-complete (5 playable exercises, Memory Album, Progress Analytics, 10
languages) and visually polished. Optional follow-ups remain: Phase 22B (Family /
Doctor Progress Review), edit/delete/replace UI for memories, or charts/trends on
the dashboard. Also: the Phase 15–24 commits are committed locally but **not
pushed** — push when ready.

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
