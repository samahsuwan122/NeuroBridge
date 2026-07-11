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

## Current state — Phase 28: Doctor Portal foundation

The **Doctor Portal** foundation is implemented as a read-only, non-diagnostic
clinical view for doctors and therapists:

- **Login** — sign in with a doctor/therapist account (clinical-only gate).
- **Dashboard overview** — assigned-patient count, recorded sessions, completion
  rate, recent activity.
- **Patients list** — assigned patients only (role-scoped), with search.
- **Patient detail** — progress summary, sessions, per-exercise performance,
  memory album review, an AI-summary placeholder, and care details.

Charts are lightweight CSS bars (no chart dependency). The AI section is a
**clearly-labeled placeholder** — no AI backend endpoint exists yet.

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

### Demo clinician (local dev only)

- Email: `doctor.demo@neurobridge.local`
- Password: `Demo12345!`

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
- `GET /api/v1/patients`, `GET /api/v1/patients/{id}` (doctor/therapist see
  assigned patients only)
- `GET /api/v1/games`, `GET /api/v1/games/results?patient_profile_id=`
- `GET /api/v1/memories`

No backend endpoints were added or changed for this foundation.

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
