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
- **Encouragement** — a clearly-labeled placeholder (no messaging endpoint
  exists yet).
- **Family safety note** — supportive view only, activity performance only, not
  a medical diagnosis and not a medical assessment; contact the care team for
  medical concerns.

Charts are lightweight CSS bars (no chart dependency). All AI/encouragement
sections are **clearly-labeled placeholders** — no such backend endpoints exist
yet.

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

Both the Doctor and Family portals reuse the same read-only endpoints; the
backend enforces role scoping. No backend endpoints were added or changed.

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
