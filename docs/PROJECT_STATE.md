# NeuroBridge — Project State / Handoff

_Last updated: 2026-07-11_

This file is a handoff/state snapshot so a future session can continue without
losing context. It complements `PROJECT_EXECUTION_PLAN.md` (roadmap).

## 1. Project name

NeuroBridge — mobile-first, smart cognitive rehabilitation and monitoring
platform. **Not a diagnostic medical system.**

## 2. Current status

- **Phase 29 Module 1F (Family Appointments Booking upgrade) completed
  locally.** Appointments are now a **real booking workflow**. Backend adds a
  `provider_availability_slots` model + migration (`0008`) and extends
  `appointments` with `provider_user_id`, `availability_slot_id`,
  `appointment_mode` (in_person/online), `location`, `meeting_url`. New APIs:
  `GET /providers` (doctors/therapists), `GET /providers/{id}/availability`
  (open slots), `POST /appointments` (book a provider + slot for the linked
  patient), `GET /appointments` (role-scoped), and `PATCH /appointments/{id}/status`.
  **RBAC (strict):** linked family can book only for the linked patient;
  unlinked family and patients cannot book; a patient can view own; a
  doctor/therapist can view appointments where they are the **provider or
  assigned** clinician and can **update status** for those only; unrelated
  clinicians are blocked; admin all; no public access. Booking **consumes** the
  slot; **cancelling reopens** it; **status is backend-controlled**. The Family
  `/appointments` page is a 3-step flow (choose provider → choose slot with
  In-person/Online + location/online note → reason → submit) plus a history
  table (provider, date/time, mode, where, status, reason). The **Doctor Portal**
  gains a functional **Appointments** page (no "Soon"): providers/assigned
  clinicians see relevant requests and Approve / Complete / Cancel them.
  `seed_demo_data` adds **6 demo slots** (Demo Doctor + Demo Therapist, in-person
  and online, next few days; idempotent). Safety wording is coordination-only
  (**appointment request / care coordination / in-person or online session /
  contact the care team / for urgent concerns contact local emergency
  services**) — non-diagnostic. **Patient-mobile appointment card is deferred**
  (mobile untouched this step; the API is ready). `website/` untouched; stash
  untouched; Family Encouragement and Family Memory Contribution still work.
- **Phase 29 Modules 1D + 1E (Family Appointments + Family Reports) completed
  locally.** **All visible Family Portal sidebar items are now functional** with
  dedicated pages — **Overview (`/`), Encouragement (`/encouragement`),
  Appointments (`/appointments`), Reports (`/reports`)** — and **no "Soon"
  badges or placeholder/disabled items remain**. The Dashboard stays an overview
  only.
  - **Module 1D — Family Appointments:** new backend `appointments` model +
    migration (`0007`) and `/api/v1/appointments` API (`GET`/`POST`). RBAC:
    **family creates/views only for a linked patient; patient views own;
    doctor/therapist view assigned; admin all; no public access; unlinked family
    blocked; audit-logged**. Validation: preferred date required, reason required
    (trimmed, non-empty, ≤ 500), preferred time optional; **status is
    backend-controlled (defaults to `pending`) — the family cannot set it**. A
    doctor status-update/approval workflow (`PATCH /status`) is **deferred** and
    documented. Web `/appointments` page: request form (loading/success/error)
    + history with status badges + empty state; safe note (**coordination only,
    not emergency care; for urgent concerns contact the care team or local
    emergency services**).
  - **Module 1E — Family Reports:** web `/reports` page composed from existing
    data (games/results, memories, encouragements, appointments, patient
    profile) — summary cards, per-exercise breakdown, recent activity, memory /
    encouragement / appointment summaries, and a working **Print report**
    action (browser print via a print stylesheet). **No new report backend, no
    fake analytics.** Wording is **performance-only, not a medical diagnosis and
    not a medical assessment**.
  - **Deferred (no UI, no fake controls):** patient-mobile appointment view and
    the Doctor-Portal appointment list are deferred this step (the backend GET
    already supports both roles). **Voice/audio encouragement remains deferred**
    as a future Module 1 enhancement — no upload buttons or disabled voice
    placeholders exist.
  - **Scope of changes:** backend (appointments model/migration/API/tests) + web
    (2 new pages, sidebar, routes, types, CSS, README) + docs. **Mobile untouched
    this step. `website/` untouched. Stash untouched. Doctor Portal, family
    memory contribution, and family/patient encouragement all still work.**
- **Phase 29 Module 1C (Family Encouragement, end-to-end + page alignment)
  completed locally.** Family/caregiver users send supportive text messages to
  their linked patient; the patient sees them on the mobile Patient Home. Backend
  adds a `family_encouragements` model + migration (`0006`) and an
  `/api/v1/encouragements` API (RBAC: **family can send only to a linked
  patient; patient can view own messages; no public access**; audit-logged). In
  the web Family Portal, **Encouragement is now a dedicated `/encouragement`
  page** (title, safety note, 300-char text form with loading/success/error
  states, message history, empty state); the **Family Dashboard stays an overview
  only** (linked patient, recent activity, games performance, memory album,
  safety note) with a **small encouragement preview + "Open encouragement"
  link**. The sidebar **Encouragement** item is a real nav link (no "Soon"
  badge). **Text encouragement is the only visible feature — voice/audio
  encouragement is planned as the next Module 1 sub-step and has no UI yet (no
  fake or disabled voice controls are shown).** Safety wording: family
  encouragement / supportive message / emotional support / **not medical advice /
  not a medical diagnosis / not a medical assessment**. `website/` untouched;
  stash untouched.
- **Phase 29 Module 1B (Family Memory Contribution) completed locally.**
  Family/caregiver users can now **add supportive memories for their linked
  patient** from the Family Portal (title, description, person, relationship,
  place, date, category, optional image). It **reuses existing backend memory
  create and media upload APIs** (`POST /memories`, then `POST /memories/{id}/media`
  for images) — **no backend changes**. **Optional JPEG/PNG/WebP image upload**
  is supported (≤ 5 MB). If the **image upload fails after the memory is created,
  the memory is kept and a clear non-blocking warning is shown**; the **album
  refreshes after saving** (`GET /memories`). **Backend, mobile, website,
  database, and migrations were untouched.** Safety wording stays **supportive
  memory contribution only — not a medical diagnosis and not a medical
  assessment**. Note: **`web/.env.local` is local only and must not be committed**
  (already covered by the `.env.*` gitignore rule). The local stash remains
  **untouched**.
- **Phase 29 Module 1 (Family Portal Foundation) completed and committed
  locally.** The **`web/`** app now serves **two role-based portals** from one
  shared sign-in: **doctor/therapist users route to the clinical dashboard**, and
  **family/caregiver users route to the family dashboard** (any other signed-in
  role sees a clear "no web access" message; patients use the mobile app).
  Implemented for family: family login support, linked patient card, recent
  activity, games performance summary, memory album view, an **encouragement
  placeholder** (no messaging endpoint exists yet), and a **family safety note**.
  It **reuses existing backend APIs read-only** (`patients`, `games`,
  `games/results`, `memories`, scoped to the family's linked patient).
  **Backend, mobile, website, database, and migrations were untouched**, and the
  **Doctor Portal remains working** unchanged. Safety wording stays supportive,
  performance-only — **not a medical diagnosis and not a medical assessment**.
- **Phase 28 (Doctor Portal Foundation) completed and committed locally.** The
  **`web/`** folder now contains the clinical **web dashboard foundation**
  (React + Vite + TypeScript) for doctors/therapists. Implemented: doctor login,
  dashboard overview, patients list, patient detail, progress summary, recent
  activity, cognitive games performance, memory album review, a **performance
  summary placeholder**, and a shared safety note. It **reuses existing backend
  APIs read-only** where possible (`auth`, `patients`, `games`, `games/results`,
  `memories`); **no backend, API, database, mobile, or website feature changes**
  were made. **The support engine is described only as supportive review, pending
  doctor/therapist review** — not a medical diagnosis and not a medical
  assessment. Separation of concerns holds: **`web/`** = clinical dashboard,
  **`website/`** = public landing site, **`mobile/`** = patient mobile app.
- **Branding standardized:** the official product name is **NeuroBridge**; the
  support engine remains only as a feature/module/descriptor. The
  roadmap file is now `docs/NEUROBRIDGE_ROADMAP.md`.
- **Phase 26 (Landing Website Foundation)** remains complete: a
  new **`website/`** folder holds a startup-grade public landing site for
  NeuroBridge. The stack is a **dependency-free
  static HTML/CSS/vanilla JS** foundation (no build step, no `node_modules`).
  Implemented sections: nav, hero, problem, solution, ecosystem, support engine,
  cognitive games, patient app, doctor portal, family portal, admin dashboard,
  reports, security, research, FAQ, contact CTA, footer. The site **distinguishes
  available features from roadmap features**, and safety wording stays
  **non-diagnostic** — the support engine is described only as **supportive**
  (supportive activity recommendations and performance summaries, pending
  doctor/therapist review; not a medical diagnosis and not a medical assessment). **Backend,
  mobile, and `web/` were untouched.**
- Preceding recent commits: **Phase 24B** expanded mobile localization coverage
  (pt/tr/de gained the full visible UI key set; en/ar already complete;
  fr/es/it/hi/id still planned for a later pass) and **Phase 25** added
  `docs/NEUROBRIDGE_ROADMAP.md` (ecosystem roadmap).
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
- Phase 25: NeuroBridge ecosystem roadmap (docs)
- Phase 26: Landing Website foundation (`website/`; dependency-free static site)
- Phase 28: Doctor Portal foundation (`web/`; React + Vite clinical dashboard)
- Phase 29 Module 1: Family Portal foundation (`web/`; family/caregiver dashboard)

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

**Phase 30 (Admin Dashboard)** or **Phase 32 (Reports)** per
`docs/NEUROBRIDGE_ROADMAP.md`, depending on project priority. The Family Portal
foundation (Phase 29 Module 1), Doctor Portal foundation (Phase 28), and public
landing website (Phase 26) are done;
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
