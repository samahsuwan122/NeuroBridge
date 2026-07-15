# NeuroBridge Web Dashboard

The clinical/administrative web dashboard for **NeuroBridge**, built with
**React + Vite + TypeScript**. It is used **only** by clinical and administrative
roles.

> **Web dashboard users:**
> - Doctor
> - Therapist
> - Admin
> - Medical center manager
>
> ⛔ **Do not build a patient web dashboard.** Patients and families/caregivers
> use the **Flutter mobile app** exclusively — see
> [`../mobile/README.md`](../mobile/README.md). This folder is also separate from
> the public marketing site in [`../website/`](../website/).

## Current state

The web app serves **two role-based portals** from one shared sign-in. After
login, role-based routing picks the portal: doctors/therapists → clinical
dashboard; families/caregivers → family dashboard; any other signed-in role → a
clear "no web access" message (patients use the mobile app).

### Phase 28 — Doctor Portal foundation

A read-only, non-diagnostic clinical view for doctors and therapists:

- **Dashboard overview** — assigned-patient count, recorded sessions, completion
  rate, recent activity.
- **Patients list** — assigned patients only (role-scoped), with search.
- **Patient detail** — progress summary, sessions, per-exercise performance,
  memory album review, an AI-summary placeholder, and care details.

### Phase 29 (Module 1) — Family Portal foundation

A supportive view for families/caregivers of their linked patient:

- **Family dashboard** — linked patient card, activity summary, recent sessions,
  games performance, and memory album view.
- **Memory contribution** — families can add a supportive memory for their
  linked patient (title, description, person, relationship, place, date,
  category, optional image). Uses `POST /memories` then, if an image was chosen,
  `POST /memories/{id}/media`; if the image upload fails the memory is kept and a
  clear non-blocking message is shown. The album refreshes via `GET /memories`.
- **Encouragement** — a dedicated **`/encouragement`** page to send a short
  supportive message to the linked patient and see recent messages (the
  dashboard keeps only a small preview + "Open encouragement" link), via
  `POST` / `GET /encouragements` (family support only). The patient sees these in
  the mobile app (Patient Home).
- **Appointments** — a dedicated **`/appointments`** booking flow: choose a
  provider (doctor/therapist), pick an available slot (in-person or online with
  location/online note), add a reason, and submit a request for the linked
  patient. History shows provider, date/time, mode, where, status, reason. Uses
  `GET /providers`, `GET /providers/{id}/availability`, `POST`/`GET
  /appointments`. Coordination only — not emergency care. The **Doctor Portal**
  `/appointments` page lets providers/assigned clinicians update status
  (`PATCH /appointments/{id}/status`). A **doctor-directory** view (search,
  role/governorate/mode/specialty filters, provider cards, and a
  **`/providers/:id`** profile page) reads rich provider data (specialty,
  governorate/city, demo rating, demo contact, photo) from `GET /providers`.
  Each provider card shows a clearly-labeled **demo contact** number.
- **Provider inquiry chat** — a real two-way conversation. From a provider card
  (**Send inquiry**) or the provider profile page (`/providers/:id#inquiry`), a
  linked family member starts a **non-urgent care-coordination** thread
  (`POST /provider-messages`). The addressed doctor/therapist opens the thread in
  the Doctor Portal **Appointments** inbox and **replies**
  (`POST /provider-messages/{id}/replies`); the family sees the reply and can
  follow up in the same thread. A dedicated family **`/messages`** page lists all
  conversations with unread badges; opening a thread marks its replies read
  (`PATCH /provider-messages/{id}/read`). The family sidebar shows an **in-app
  unread badge** (polled from `GET /provider-messages/unread-count` every 30s —
  in-app only, **no browser/push notifications**). Chat bubbles, sender, and time
  render like a clinic messenger. Non-urgent only — not emergency care.

  > **Demo providers & photos.** All providers are **local graduation-demo data,
  > not real clinicians** — names, ratings, and the demo contact numbers (e.g.
  > `+970-59-410-2301`) are **fake demo values only**, seeded per provider and
  > never real phone numbers. Provider **photos are uploaded by an admin via
  > Swagger** (`POST /api/v1/providers/{id}/photo`, admin-only, JPEG/PNG/WebP ≤ 5
  > MB); files are stored in **`backend/storage/provider_photos/`** (git-ignored)
  > and the database keeps only the `photo_url`. Cards/profile fall back to an
  > initials avatar when no photo exists.
- **Reports** — a dedicated **`/reports`** page: a performance-only family
  summary (sessions, completion, best/average, memories, encouragements,
  appointment requests, per-exercise breakdown) with a **Print report** action
  (browser print; a print stylesheet hides the app chrome). Composed from
  existing data — no new report backend.
- **Family safety note** — supportive view only, activity performance only, not
  a medical diagnosis and not a medical assessment; contact the care team for
  medical concerns.

Charts are lightweight CSS bars (no chart dependency). The Doctor Portal AI
section remains a **clearly-labeled placeholder** — no AI backend exists yet.

## Stack

- React 19 + TypeScript
- Vite 6 (dev server on `http://localhost:5173`, already in the backend CORS
  allowlist)
- React Router
- Plain CSS (premium medical theme; no CSS framework)

## Install

```bash
cd web
npm install
```

## Run (dev)

Start the backend first (see [`../backend`](../backend) / the root README), then:

```bash
cd web
npm run dev        # http://localhost:5173
```

Configure the API base URL with `web/.env` if the backend is not on
`http://localhost:8000`:

```
VITE_API_BASE_URL=http://localhost:8000
```

### Demo accounts (local dev only)

- Clinician: `doctor.demo@neurobridge.local` (or `therapist.demo@…`)
- Family: `family.demo@neurobridge.local`
- Password (all): `Demo12345!`

(Seed with `python -m app.scripts.seed_demo_data` in the backend.)

## Type-check & build

```bash
cd web
npm run typecheck  # tsc --noEmit
npm run build      # tsc --noEmit && vite build  -> dist/
npm run preview    # preview the production build
```

## Backend APIs reused (read-only)

- `POST /api/v1/auth/login`, `GET /api/v1/auth/me`, `POST /api/v1/auth/logout`
- `GET /api/v1/patients`, `GET /api/v1/patients/{id}` — role-scoped: doctors/
  therapists see assigned patients; families see their linked patient(s).
- `GET /api/v1/games`, `GET /api/v1/games/results?patient_profile_id=` —
  results are role-scoped the same way.
- `GET /api/v1/memories` — role-scoped (families see their linked patient's).
- `GET` / `POST /api/v1/encouragements` — family encouragement messages
  (family/admin create for a linked patient; role-scoped listing).
- `GET` / `POST /api/v1/appointments` — family appointment requests
  (family/admin create for a linked patient; role-scoped listing; status is
  backend-controlled, defaults to `pending`).
- `GET` / `POST /api/v1/provider-messages` — non-urgent provider inquiry threads
  (family/admin create for a linked patient, addressed to a provider; providers
  read inquiries addressed to them; role-scoped listing with reply preview +
  unread count).
- `GET /api/v1/provider-messages/{id}` — a full thread (inquiry + replies).
- `POST /api/v1/provider-messages/{id}/replies` — reply in a thread (addressed
  provider, family sender, or admin).
- `PATCH /api/v1/provider-messages/{id}/read` — mark the thread's replies read.
- `GET /api/v1/provider-messages/unread-count` — in-app unread reply count.

The portals reuse the same role-scoped endpoints; the backend enforces scoping.
The `encouragements` and `appointments` endpoints were added (each with model,
migration, and tests) for the Family Portal features.

## Planned features (later phases)

- Appointments, PDF reports, AI recommendation review queue (approve / edit /
  reject; recommendations stay pending until reviewed)
- Admin user management, audit logs, medical center manager reports

## Safety reminder

NeuroBridge is **not a diagnostic medical system**. No page or generated text may
claim to diagnose any condition. All summaries reflect **cognitive exercise
performance only**. AI output is always an **AI-assisted, non-diagnostic support
recommendation** that is **not a medical diagnosis and not a medical assessment**
and stays **pending doctor/therapist review**. See [`../CLAUDE.md`](../CLAUDE.md).
