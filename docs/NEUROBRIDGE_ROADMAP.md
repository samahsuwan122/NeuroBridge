# NeuroBridge — Roadmap & Ecosystem Architecture

**AI-Powered Cognitive Rehabilitation Ecosystem**

_Strategic roadmap document. Phase 25._
_Status: planning / vision. This file is documentation only — it does not change
any code, API, database, or behavior._

> **Medical safety notice.** NeuroBridge is **not** a diagnostic medical
> system. Nothing in this roadmap describes diagnosing, predicting, scoring, or
> treating any disease or condition. All AI output is an **AI-assisted support
> recommendation — not a medical diagnosis and not a medical assessment — and
> requires review by a qualified doctor or therapist.** Games and exercises
> measure **game performance only**.

---

## 1. Executive Vision

NeuroBridge is **not** just a mobile app, and **not** just a set of memory
games. It is an **AI-powered cognitive rehabilitation ecosystem** that connects
the patient, the family, the doctor, and the care center around one shared,
structured, day-by-day support journey.

The vision is a startup-grade platform where:

- **Patients** train with simple, accessible, supportive daily activities on a
  mobile app.
- **Families / caregivers** stay connected, follow along, encourage, and
  contribute memories and context.
- **Doctors / therapists** review activity performance, build supportive
  session plans, and keep clinical oversight through a web portal.
- **Admins / center managers** run the platform: users, content, centers,
  analytics, and audit trails.
- An **AI Core** proposes supportive activity suggestions and plain-language
  performance summaries — always **pending professional review**, never acting
  as a clinician.

The product should feel like a real medical-grade platform: coherent design
language, multi-role access, strong documentation, safe AI boundaries, and a
cloud-ready architecture — well beyond a typical single-screen student app.

The name captures the intent: **bridging memory, connecting lives** — a bridge
between the patient's daily effort and the care team's oversight.

---

## 2. Core Problem

Cognitive rehabilitation and daily cognitive support face real, well-documented
gaps:

- **Limited daily follow-up.** Care often happens in occasional appointments,
  while the day-to-day is unstructured and unobserved.
- **Disconnected experiences.** The patient, the family, and the doctor each
  hold a fragment of the picture, with no shared, continuous view.
- **Lack of structured cognitive training.** Practice activities are ad hoc,
  inconsistent, and rarely organized into progressive categories.
- **Weak progress visibility.** It is hard to see, in plain language, how daily
  activity is trending over time — for the patient, the family, or the doctor.
- **Need for safe AI-assisted support.** There is room for AI to help suggest
  supportive activities and summarize performance — **but only within strict,
  professionally-reviewed boundaries**, never as an autonomous medical
  authority.

NeuroBridge addresses these gaps with a connected ecosystem: consistent daily
activities, a shared multi-role view, structured training categories, clear
performance summaries, and AI assistance that always stays **supportive and
pending review**.

---

## 3. Product Modules

| Module | Platform | Purpose |
| --- | --- | --- |
| **Landing Website** | Web | Public presentation of the vision, modules, and value; entry point and credibility. |
| **Patient Mobile App** | Flutter (mobile-first) | Simple, accessible daily activities, memory album, reminders, progress, and AI support. |
| **Doctor Portal** | Web dashboard | Assigned-patient oversight, session planning, performance review, appointments, and AI review queue. |
| **Family Portal** | Web / mobile experience | Follow linked patient progress, encourage, and contribute memories and notes. |
| **Admin Dashboard** | Web dashboard | Manage users, centers, content, analytics, notifications, settings, and audit logs. |
| **AI Core** | Backend service | Generate supportive activity suggestions and performance summaries — always pending professional review. |
| **Reports Engine** | Backend service | Compose patient / family / doctor / monthly reports with charts and PDF export. |
| **Security Layer** | Cross-cutting | JWT auth, RBAC, password hashing, audit logging, and role-scoped data access. |
| **Cloud Deployment** | Infrastructure | Cloud-ready hosting, storage, and future CI/CD. |

**Module boundaries.** Each module is a separable domain. The mobile app talks
to the backend only through the REST API; the AI Core produces suggestions that
are **stored as pending** and surfaced to doctors for review; the Reports Engine
composes from stored, performance-only data.

---

## 4. User Roles

- **Patient.** Uses the mobile app for daily supportive activities, memory
  album, reminders, and progress. UI is simple, large-button, and accessible.
  Cannot access doctor/admin areas.
- **Family / Caregiver.** Views linked patient progress only, encourages, and
  contributes memories, photos/audio, and notes. Cannot access clinical
  controls.
- **Doctor.** Reviews assigned patients only, plans supportive sessions, reads
  performance summaries and reports, and acts on the AI review queue. Provides
  the required professional review of AI suggestions.
- **Therapist.** Similar scope to the doctor for assigned patients — focused on
  supportive session planning and activity review, within professional
  boundaries.
- **Admin / Center Manager.** Manages users, doctors, centers, content, system
  settings, and audit logs. Does not perform clinical review.

Role-based access control (RBAC) enforces these boundaries at the API layer:
patients cannot reach clinical pages, families see only linked patients, doctors
see only assigned patients, and admins manage the platform but not clinical
review.

---

## 5. Patient App Roadmap (mobile)

The patient experience stays **simple, accessible, and supportive**:

- **Daily session** — a guided, low-friction set of supportive activities for
  the day.
- **Daily goal** — a gentle, encouraging target (e.g., complete today's
  session), never framed as a medical target.
- **Cognitive training categories** — activities organized into clear groups
  (see §10) so practice is structured rather than ad hoc.
- **Memory album** — photos and stories that also power supportive recall
  activities, contributed by patient and family.
- **AI assistant** — surfaces supportive activity suggestions and plain-language
  encouragement; **all suggestions are pending doctor/therapist review**.
- **Medication reminders** — simple reminders for medications and appointments
  (organizational support, not medical advice).
- **Progress** — performance-only summaries of recent activity, in plain
  language.
- **Achievements** — encouraging milestones for consistency and effort.
- **Calendar** — a friendly view of sessions, reminders, and appointments.
- **Reports** — a readable, performance-only summary the patient can view and
  share with family or the care team.

All patient-facing text remains safe wording: **performance only, supportive
activity, not a medical assessment**. Arabic screens support RTL; other
languages are LTR. Full 10-language coverage is a first-class requirement.

---

## 6. Doctor Portal Roadmap (web)

The doctor/therapist portal provides clinical **oversight**, not automation of
clinical judgment:

- **Doctor dashboard** — an at-a-glance view of assigned patients and items
  needing attention.
- **Patients** — the assigned-patient list with performance-only overviews.
- **Sessions** — view completed supportive sessions and activity history.
- **Reports** — read and export patient performance reports.
- **Analytics** — performance trends and summaries across assigned patients.
- **Appointments** — schedule and track appointments.
- **Memory album review** — review family-contributed memories used in
  supportive recall activities.
- **Family notes** — read context and notes contributed by families.
- **AI summary** — read AI-generated **performance summaries** with the standard
  disclaimer; the doctor confirms or edits.
- **AI therapy session builder** — assemble a supportive session plan; AI can
  **propose** a draft, but every AI proposal stays **pending until the doctor or
  therapist approves it**.

The portal always makes the boundary explicit: AI output is a support
recommendation, **not a medical diagnosis and not a medical assessment**, and
requires professional review.

---

## 7. Family Portal Roadmap

The family/caregiver experience is **connection and contribution**, scoped
strictly to linked patients:

- **Patient progress** — performance-only progress for the linked patient.
- **Session completion** — see whether daily sessions were completed.
- **Encouragement** — send simple encouragement and supportive messages.
- **Upload memories** — contribute memories that power supportive recall
  activities.
- **Upload photos / audio** — add media to the memory album (securely handled).
- **Family notes** — add context and notes for the care team.
- **Appointments** — view upcoming appointments for the linked patient.

Families never see other patients' data and never access clinical controls.

---

## 8. Admin Dashboard Roadmap (web)

The admin/center-manager dashboard runs the platform:

- **Users** — manage patient/family/doctor/therapist accounts.
- **Doctors** — manage clinicians and their patient assignments.
- **Hospitals / centers** — manage medical centers and their memberships.
- **Games** — manage the catalog of supportive activities.
- **Sessions** — oversee session definitions and history.
- **Analytics** — platform-level, performance-only analytics.
- **Reports** — platform reporting and export.
- **Feedback** — collect and triage user feedback.
- **Content** — manage localized content and educational material.
- **Notifications** — manage in-app and push notifications.
- **System settings** — configure platform behavior and defaults.
- **Audit logs** — review sensitive-action logs (login, profile update, notes,
  report generation, AI recommendation review).

Admins manage the system but do **not** perform clinical review; that stays with
doctors and therapists.

---

## 9. AI Module Roadmap

The AI Core is a **supportive assistant**, never a clinician. Its scope:

- **AI Therapy Generator** — proposes a draft supportive session plan for a
  patient. Output is **pending until doctor/therapist approval**.
- **AI Difficulty Adjustment** — suggests gentler or fuller activity variants
  based on recent **game performance only**.
- **AI Recommendation Engine** — proposes supportive activity suggestions.
- **AI Weekly Report** — composes a plain-language **performance summary** for
  review and sharing.
- **AI Prompt Builder** — structures safe, bounded prompts/templates so AI
  output stays inside supportive, non-diagnostic language.
- **AI Analytics** — surfaces performance trends to support (not replace)
  professional judgment.
- **Doctor Review Queue** — every AI suggestion lands here as **pending** and is
  only activated after a doctor or therapist reviews it.

### AI safety boundaries (non-negotiable)

The AI must **never** be described or built as diagnosing, predicting disease,
scoring a condition, or replacing clinicians. Approved wording only:

- **AI-assisted recommendations**
- **Supportive activity suggestions**
- **Performance summaries**
- **Requires doctor / therapist review**
- **Not a medical diagnosis**
- **Not a medical assessment**

Every AI recommendation or report must carry the idea: _"AI-generated support
recommendation. Not a medical diagnosis. Requires review by a qualified doctor
or therapist."_ AI therapy recommendations stay **pending** until professional
approval.

---

## 10. Game Expansion Roadmap

Supportive activities are grouped into clear categories so training is
structured and progressive. All are **cognitive exercises measuring game
performance only** — never a medical assessment.

**Categories**

- **Memory**
- **Attention**
- **Language**
- **Logic**
- **Executive Function**
- **Visual**
- **Daily Activities**
- **Reaction**

**Current games (implemented)**

- Memory Match
- Memory Recall
- Reaction Time
- Attention Focus
- Sequence Recall

**Future games (planned)**

| Game | Suggested category |
| --- | --- |
| Object Recall | Memory |
| Shopping List | Memory / Daily Activities |
| Daily Routine | Daily Activities / Executive Function |
| Visual Search | Attention / Visual |
| Word Builder | Language |
| Face Recognition | Memory / Visual |
| Color Recall | Memory / Visual |
| Pattern Memory | Memory / Logic |
| Sound Memory | Memory |
| Clock Training | Executive Function / Daily Activities |
| Medication Sorting | Daily Activities / Executive Function |

Every game reports **performance-only** results (score, duration, completion),
feeding progress summaries and reports without any medical interpretation.

---

## 11. Reports Roadmap

The Reports Engine composes readable, **performance-only** reports:

- **Patient weekly report** — a friendly, plain-language weekly performance
  summary.
- **Family summary** — a short summary for linked families.
- **Doctor review report** — a fuller performance report for the care team,
  with the standard disclaimer.
- **Monthly report** — a longer-horizon performance trend summary.
- **Charts** — visual trends (e.g., activity over time, per-category
  performance) using safe, performance-only framing.
- **PDF export** — shareable, well-formatted PDF output.
- **Progress trends** — performance direction over time, never a clinical score.

Reports never claim diagnosis or medical interpretation; they present activity
and performance, and always mark AI-derived content as requiring professional
review.

---

## 12. Security and Privacy

Protecting sensitive, health-related data is a first-class requirement:

- **JWT** — access tokens with refresh tokens for authentication.
- **RBAC** — strict role-based access control at the API layer (patient /
  family / doctor / therapist / admin scopes).
- **Audit logs** — logging of sensitive actions: login, profile update, notes,
  report generation, and AI recommendation review.
- **Password hashing** — passwords stored only as bcrypt/Argon2 hashes, never in
  plain text.
- **Role-based data access** — families see only linked patients; doctors see
  only assigned patients; admins manage but do not perform clinical review.
- **Future encryption** — encryption of sensitive data at rest and in transit as
  a planned enhancement.
- **Secure file uploads** — validated type/size, safe storage, and controlled
  access for memory-album media.

---

## 13. Cloud-Ready Architecture

The platform is designed to move cleanly from local development to the cloud:

- **GitHub** — source control and collaboration.
- **FastAPI** — Python REST backend.
- **Flutter** — mobile-first client (with web-friendly layouts).
- **PostgreSQL** — relational database.
- **Cloud storage** — for memory-album media and generated reports.
- **Future deployment** — managed cloud hosting for backend, database, and web
  dashboards.
- **CI/CD (future work)** — automated build, test, and deployment pipelines.

The current stack already separates concerns (client ↔ REST API ↔ database),
which keeps the path to cloud deployment straightforward.

---

## 14. Practical Execution Phases

A realistic, phased plan from roadmap to presentation:

| Phase | Focus | Summary |
| --- | --- | --- |
| **Phase 25** | Roadmap | This document — vision, modules, roles, and phased plan. |
| **Phase 26** | Landing Website | Public site presenting the ecosystem and value. |
| **Phase 27** | Patient App 2.0 | Daily session, goals, achievements, calendar, richer progress. |
| **Phase 28** | Doctor Portal | Assigned-patient oversight, sessions, reports, appointments. |
| **Phase 29** | Family Portal | Linked-patient progress, encouragement, memory contribution. |
| **Phase 30** | Admin Dashboard | Users, centers, content, analytics, notifications, audit logs. |
| **Phase 31** | AI Core | Supportive suggestions and summaries with a doctor review queue. |
| **Phase 32** | Reports | Patient/family/doctor/monthly reports, charts, PDF export. |
| **Phase 33** | Full Localization | Complete 10-language coverage across all modules. |
| **Phase 34** | Testing & Deployment | End-to-end testing and cloud-ready deployment. |
| **Phase 35** | Final Report & Presentation | Documentation, demo, and graduation presentation. |

Each phase is delivered as **small vertical features** (backend + client +
tests) rather than one large build, keeping the system stable and demoable at
every step.

---

## 15. Graduation Differentiation

Why NeuroBridge is stronger than a typical student app:

- **Ecosystem approach.** A connected platform (website, mobile app, portals,
  dashboards, AI, reports), not a single screen.
- **Multi-role platform.** Patient, family, doctor, therapist, and admin roles
  with real, enforced boundaries.
- **AI-driven rehabilitation journey.** A structured, day-by-day supportive
  journey — with AI assistance inside safe limits.
- **Doctor / family / patient integration.** One shared, continuous view across
  the people who matter to care.
- **Safe AI boundaries.** AI is explicitly supportive and **pending review** —
  never diagnostic, never a clinician replacement.
- **Professional UI/UX.** A coherent, accessible, premium medical design
  language, with RTL and 10-language support.
- **Cloud-ready architecture.** Clean client ↔ API ↔ database separation with a
  clear path to cloud deployment and CI/CD.
- **Strong documentation.** SRS alignment, execution plan, project-state
  handoffs, and this ecosystem roadmap.

Together these turn a "final-year project" into a **credible, startup-grade
platform vision** — safe, structured, connected, and well-documented.

---

_This is a strategic planning document only. It introduces no medical claims:
NeuroBridge does not diagnose, predict, score, or treat any condition. All AI
output is an AI-assisted support recommendation — not a medical diagnosis and not
a medical assessment — and requires review by a qualified doctor or therapist._
