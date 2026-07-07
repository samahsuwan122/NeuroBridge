# NeuroBridge Web Dashboard

The web dashboard is built with **React + Vite**. It is used **only** by clinical and administrative
roles.

> **Web dashboard users:**
> - Doctor
> - Therapist
> - Admin
> - Medical center manager
>
> ⛔ **Do not build a patient web dashboard.** Patients and families/caregivers use the
> **Flutter mobile app** exclusively — see [`../mobile/README.md`](../mobile/README.md).

In Phase 1 this folder is **foundation only** (this README). The React + Vite project is scaffolded
in a later phase per [`../PROJECT_EXECUTION_PLAN.md`](../PROJECT_EXECUTION_PLAN.md).

## Planned features (later phases)

- Doctor dashboard
- Patient review pages (for assigned patients only)
- Therapy plan management
- AI recommendation review (approve / edit / reject; recommendations stay pending until reviewed)
- PDF reports
- Admin user management
- Audit logs
- Medical center manager reports

Access is governed by role-based access control (RBAC): a doctor/therapist sees only assigned
patients, a manager sees only center-level data, and an admin manages users/roles/centers/audit logs.

## Commands (activated when the Vite project is scaffolded)

```bash
cd web
npm install
npm run dev        # http://localhost:5173
```

## Safety reminder

NeuroBridge is **not a diagnostic medical system**. No page or generated text may claim to diagnose
any condition. AI output is always a non-diagnostic support recommendation pending doctor/therapist
review. See [`../CLAUDE.md`](../CLAUDE.md).
