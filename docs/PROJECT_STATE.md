# NeuroBridge — Project State / Handoff

_Last updated: 2026-07-11_

This file is a handoff/state snapshot so a future session can continue without
losing context. It complements `CLAUDE.md` (rules) and
`PROJECT_EXECUTION_PLAN.md` (roadmap).

## 1. Project name

NeuroBridge — mobile-first, AI-powered cognitive rehabilitation and monitoring
platform. **Not a diagnostic medical system.**

## 2. Current status

- **Phase 26 (Landing Website Foundation) completed and committed locally.** A
  new **`website/`** folder holds a startup-grade public landing site for
  NeuroBridge AI. **`web/` remains reserved** for future doctor/therapist/admin
  dashboards (React + Vite) and was untouched. The stack is a **dependency-free
  static HTML/CSS/vanilla JS** foundation (no build step, no `node_modules`).
  Implemented sections: nav, hero, problem, solution, ecosystem, AI engine,
  cognitive games, patient app, doctor portal, family portal, admin dashboard,
  reports, security, research, FAQ, contact CTA, footer. The site **distinguishes
  available features from roadmap features**, and safety wording stays
  **non-diagnostic** — AI is described only as **AI-assisted support** (supportive
  activity recommendations and performance summaries, pending doctor/therapist
  review; not a medical diagnosis and not a medical assessment). **Backend,
  mobile, and `web/` were untouched.**
- Preceding recent commits: **Phase 24B** expanded mobile localization coverage
  (pt/tr/de gained the full visible UI key set; en/ar already complete;
  fr/es/it/hi/id still planned for a later pass) and **Phase 25** added
  `docs/NEUROBRIDGE_AI_ROADMAP.md` (ecosystem roadmap).
- A local stash `stash@{0}` ("wip phase 24b partial game localization") remains
  **untouched** (not restored).
- Commits are **not pushed yet** (`origin/main` is behind local `main`).

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
- Phase 24B: Expanded localization coverage (mobile; pt/tr/de full UI key set)
- Phase 25: NeuroBridge AI ecosystem roadmap (docs)
- Phase 26: Landing Website foundation (`website/`; dependency-free static site)

## 4. Demo login (LOCAL DEV ONLY — fake accounts)

- Email: `patient.demo@neurobridge.local`
- Password: `Demo12345!`

(Other demo roles use the same password: `admin.demo@`, `family.demo@`,
`doctor.demo@`, `therapist.demo@` `@neurobridge.local`. Created by
`python -m app.scripts.seed_demo_data`.)

## 5. Current working feature

None in progress. **Phase 26 — Landing Website Foundation is complete and
committed** (see §2). The most recent *mobile* feature was **Phase 24A — Final
Design Upgrade**: mobile-only styling of the shared theme foundation
(`core/theme/app_theme.dart`,
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

**Phase 27 (Patient App 2.0)** or **Phase 28 (Doctor Portal foundation)** per
`docs/NEUROBRIDGE_AI_ROADMAP.md`. The public landing website (Phase 26) is done;
the patient app remains feature-complete (5 playable exercises, Memory Album,
Progress Analytics, 10 language directions) and visually polished. Remaining
localization languages (fr/es/it/hi/id) can be completed in a later pass.
Optional mobile follow-ups also remain: Phase 22B (Family / Doctor Progress
Review), edit/delete/replace UI for memories, or charts/trends on the dashboard.
Commits are local and **not pushed** — push when ready.

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
