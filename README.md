# NeuroBridge

NeuroBridge is a **mobile-first, AI-powered cognitive rehabilitation and monitoring platform**.
It helps patients complete cognitive exercises and therapy activities, lets families/caregivers
follow along, and gives doctors, therapists, and administrators the tools to review progress and
coordinate care.

> ⚠️ **NeuroBridge is NOT a diagnostic medical system.**
> It does not diagnose Alzheimer's, dementia, stroke, cognitive impairment, or any other medical
> condition. All AI output is a **non-diagnostic support recommendation that requires review by a
> qualified doctor or therapist** before it is acted upon.

This is a final-year software/computer engineering project. Implementation follows the phased plan in
[`PROJECT_EXECUTION_PLAN.md`](PROJECT_EXECUTION_PLAN.md) and the project rules in
[`CLAUDE.md`](CLAUDE.md).

---

## Main modules

| Module | Technology | Who uses it |
|--------|------------|-------------|
| **Mobile app** | Flutter | **Patient** and **Family / caregiver** |
| **Web dashboard** | React + Vite | **Doctor, Therapist, Admin, Medical center manager** |
| **Backend API** | FastAPI (Python) | All clients |
| **Official database** | PostgreSQL | Production / project database |
| **Local-dev database** | SQLite (fallback) | Selected automatically via `DATABASE_URL` |
| **AI recommendation module** | Rule-based first (optional templated summaries later) | Doctor/therapist review workflow |
| **PDF reports** | Backend PDF generation | Doctor / admin / manager |
| **Notifications** | In-app first (Firebase Cloud Messaging later) | Patient / family / doctor |
| **Audit logs** | Backend | Sensitive actions (login, notes, reports, AI review, etc.) |
| **Localization** | Arabic 🇸🇦 & English 🇬🇧 (RTL for Arabic) | All clients |

**Important architecture note:** the patient and family/caregiver experience is **Flutter mobile-only**.
There is **no patient web dashboard**. The web dashboard is exclusively for clinical/administrative
roles (doctor, therapist, admin, manager).

---

## Repository structure

```text
NB Project/
  CLAUDE.md                    # Project rules and guardrails
  PROJECT_EXECUTION_PLAN.md    # Phase-by-phase execution plan
  README.md                    # This file
  .gitignore
  .env.example                 # Copy to .env and fill in

  docs/                        # Project documentation
  backend/                     # FastAPI backend (Python)
  mobile/                      # Flutter app (patient + family)
  web/                         # React + Vite dashboard (clinical/admin)
  docker/                      # Container/deployment notes (added later)
```

---

## Setup

Code is implemented **phase by phase** — most folders are foundation-only right now. The commands
below describe how each part will be run once its phase is implemented. See each subfolder's
`README.md` for details.

### 1. Environment variables

```bash
# From the project root
cp .env.example .env          # Windows PowerShell: Copy-Item .env.example .env
# then edit .env and set JWT_SECRET_KEY and any other secrets
```

### 2. Backend (FastAPI) — activated in Phase 2

Python **3.11+** is recommended. See [`backend/README.md`](backend/README.md).

```bash
cd backend
py -m venv .venv
# Windows:  .venv\Scripts\activate
# Unix:     source .venv/bin/activate
pip install -r requirements.txt
# Run command becomes available in Phase 2:
# uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

### 3. Mobile (Flutter) — activated in a later phase

For patient and family/caregiver. See [`mobile/README.md`](mobile/README.md).

```bash
cd mobile
flutter pub get
flutter run
```

### 4. Web dashboard (React + Vite) — activated in a later phase

For doctor, therapist, admin, and manager only. See [`web/README.md`](web/README.md).

```bash
cd web
npm install
npm run dev        # served on http://localhost:5173
```

### 5. Database

- **Local development:** SQLite is used automatically. `DATABASE_URL=sqlite:///./neurobridge_dev.db`
  requires no database server.
- **Production / project database:** PostgreSQL. Point `DATABASE_URL` at your PostgreSQL instance
  (see `POSTGRES_DATABASE_URL` in `.env.example` for the expected format).
- Migrations and models are introduced in **Phase 3**.

---

## Development approach

NeuroBridge is built **incrementally, one phase and one vertical feature at a time** — never all at
once. Each phase inspects the codebase first, makes the smallest safe change, respects role-based
access control and the medical-safety rules, and updates its checklist. The full roadmap is in
[`PROJECT_EXECUTION_PLAN.md`](PROJECT_EXECUTION_PLAN.md).
