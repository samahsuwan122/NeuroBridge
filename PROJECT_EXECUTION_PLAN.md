# NeuroBridge Practical Execution Plan for Claude Code

## 0. Project Identity

Project name: NeuroBridge
Project type: Mobile-first AI-powered cognitive rehabilitation and monitoring platform
Main stack:

* Mobile app: Flutter
* Backend API: FastAPI
* Database: PostgreSQL
* Web dashboard: React / Next.js or React + Vite
* AI module: Python rule-based engine first, optional LLM/template summaries later
* Notifications: in-app first, Firebase Cloud Messaging later
* Reports: PDF generation
* Languages: Arabic and English
* Security: JWT, RBAC, audit logs, password hashing

## 1. Core Rule for Claude Code

Do not build the whole system at once.

Work phase by phase.
Work task by task.
Before coding each task:

1. Inspect the current codebase.
2. Explain the plan briefly.
3. List files that will be changed.
4. Implement only the requested task.
5. Run tests/build/format commands if available.
6. Fix errors.
7. Update the TODO checklist.
8. Summarize what changed and how to test it.

## 2. Medical and AI Safety Rules

NeuroBridge is not a medical diagnostic system.

Never write code, UI text, API responses, report text, or AI output that claims to diagnose:

* Alzheimer’s disease
* Dementia
* Stroke
* Cognitive impairment
* Neurological disease
* Mental health conditions
* Any medical condition

Every AI-generated recommendation or summary must include this idea:

“AI-generated support recommendation. Not a medical diagnosis. Requires review by a qualified doctor or therapist.”

AI recommendations must not become active automatically.
They must stay pending until approved, edited, or rejected by a doctor/therapist.

Use neutral phrases:

* “may require review”
* “needs therapist review”
* “monitoring indicator”
* “support recommendation”
* “non-diagnostic summary”

Avoid unsafe phrases:

* “the patient has dementia”
* “the system detected Alzheimer’s”
* “cognitive decline confirmed”
* “diagnosis”
* “medical certainty”

## 3. System Roles

Implement these roles:

1. Patient
2. Family member / caregiver
3. Doctor
4. Therapist
5. Admin
6. Medical center manager

Access rules:

* Patient can access only their own mobile features.
* Family member can access only linked patient summaries/reminders/alerts.
* Doctor/therapist can access only assigned patients.
* Admin can manage users, roles, centers, audit logs, and settings.
* Manager can view center-level users, patients, and reports.
* No user should access unrelated patient data.

## 4. Recommended Monorepo Structure

Use this structure unless the existing repository already has a better structure:

```text
neurobridge/
  CLAUDE.md
  PROJECT_EXECUTION_PLAN.md
  README.md
  .gitignore
  .env.example

  docs/
    SRS.docx
    API_CONTRACT.md
    DATABASE_SCHEMA.md
    DEMO_SCRIPT.md

  backend/
    app/
      main.py
      core/
        config.py
        security.py
        database.py
        permissions.py
      modules/
        auth/
        users/
        patients/
        doctors/
        family/
        therapy/
        games/
        assessments/
        reminders/
        notifications/
        ai/
        reports/
        files/
        audit/
        admin/
      tests/
    alembic/
    requirements.txt
    pyproject.toml

  mobile/
    lib/
      main.dart
      core/
      features/
        auth/
        patient_home/
        games/
        therapy/
        reminders/
        progress/
        family/
        settings/
      l10n/
    pubspec.yaml

  web/
    src/
      app/
      components/
      features/
        auth/
        doctor_dashboard/
        admin_dashboard/
        reports/
        patients/
        therapy/
      lib/
    package.json

  docker/
    docker-compose.yml
```

## 5. Global Definition of Done

A task is done only when:

* The feature is implemented in the correct module.
* RBAC is respected.
* Input validation exists.
* Sensitive actions create audit logs where required.
* No diagnostic medical language is used.
* Tests or manual test steps are provided.
* The project still builds/runs.
* The TODO checklist is updated.

## 6. Phase 0 — Repository Inspection and Setup Plan

Goal: Understand the existing project before editing.

Claude Code prompt:

```text
Read the current repository and PROJECT_EXECUTION_PLAN.md. Do not edit files yet.

Inspect:
- existing folder structure
- existing Flutter code
- existing backend code
- existing web dashboard code
- existing dependencies
- README or setup files
- environment files
- database/migration files

Then produce:
1. Current project structure summary
2. What already exists
3. What is missing
4. Recommended next step
5. Whether the repository should be reorganized or preserved

Do not implement anything yet.
```

TODO:

* [ ] Inspect repository structure
* [ ] Identify existing frontend/backend/mobile code
* [ ] Identify missing files
* [ ] Identify available run commands
* [ ] Identify errors or broken setup
* [ ] Propose safe starting point

Acceptance criteria:

* No code changed.
* Clear report is produced.
* Next task is recommended.

## 7. Phase 1 — Project Foundation

Goal: Create a clean foundation for the monorepo.

Claude Code prompt:

```text
Implement Phase 1: Project Foundation.

Scope:
- Create or fix basic project structure.
- Add README.md with setup instructions.
- Add .env.example.
- Add .gitignore.
- Add docs folder.
- Add backend, mobile, and web folders only if missing.
- Do not implement business features yet.

Before editing, inspect the repo and list exact files to create/change.
After editing, show the final structure and how to run each part.
```

TODO:

* [ ] Create README.md
* [ ] Create `.env.example`
* [ ] Create `.gitignore`
* [ ] Create `docs/`
* [ ] Add SRS reference under docs if available
* [ ] Create backend folder if missing
* [ ] Create mobile folder if missing
* [ ] Create web folder if missing
* [ ] Document setup commands
* [ ] Document project architecture

Acceptance criteria:

* Repository has clear structure.
* New developer can understand how to start.
* No unnecessary feature code yet.

## 8. Phase 2 — Backend Skeleton

Goal: Start FastAPI backend with clean modular architecture.

Claude Code prompt:

```text
Implement Phase 2: Backend Skeleton.

Scope:
- FastAPI backend only.
- Create app entry point.
- Add config management.
- Add health check endpoint.
- Add database connection placeholder.
- Add modular folders.
- Add basic test for health check if testing framework exists.

Endpoints:
- GET /health
- GET /api/v1/health

Do not implement authentication yet.
```

TODO:

* [ ] Create `backend/app/main.py`
* [ ] Create `backend/app/core/config.py`
* [ ] Create `backend/app/core/database.py`
* [ ] Create modules folder
* [ ] Add health routes
* [ ] Add requirements or pyproject dependencies
* [ ] Add basic test
* [ ] Confirm backend runs

Acceptance criteria:

* Backend starts successfully.
* Health endpoint returns success.
* Folder structure supports future modules.

## 9. Phase 3 — Database Foundation

Goal: Add PostgreSQL models and migration foundation.

Claude Code prompt:

```text
Implement Phase 3: Database Foundation.

Scope:
- Backend only.
- Configure SQLAlchemy or SQLModel.
- Configure PostgreSQL connection.
- Add Alembic migrations.
- Add base model fields:
  - id UUID
  - created_at
  - updated_at
  - deleted_at where useful

Create initial database models only for:
- Users
- Roles
- UserRoles
- MedicalCenters
- AuditLogs

Do not implement auth endpoints yet.
```

TODO:

* [ ] Configure database session
* [ ] Configure migrations
* [ ] Create Users model
* [ ] Create Roles model
* [ ] Create UserRoles model
* [ ] Create MedicalCenters model
* [ ] Create AuditLogs model
* [ ] Add initial migration
* [ ] Add seed roles script

Acceptance criteria:

* Migration runs.
* Tables are created.
* Roles can be seeded.

## 10. Phase 4 — Authentication and RBAC

Goal: Secure login and role-based access.

Claude Code prompt:

```text
Implement Phase 4: Authentication and RBAC.

Scope:
- Backend only.
- Implement secure login.
- Implement password hashing.
- Implement JWT access token.
- Add refresh token structure if reasonable.
- Add current user endpoint.
- Add role guard helpers.
- Add audit log for login.

Endpoints:
- POST /api/v1/auth/login
- POST /api/v1/auth/logout
- POST /api/v1/auth/refresh
- GET /api/v1/auth/me

Security:
- Passwords must be hashed.
- Invalid login must return safe error.
- Protected routes must require token.
- Unauthorized role must return 403.
```

TODO:

* [ ] Add password hashing
* [ ] Add JWT creation
* [ ] Add login endpoint
* [ ] Add logout endpoint placeholder
* [ ] Add refresh endpoint placeholder or implementation
* [ ] Add current user endpoint
* [ ] Add auth dependency
* [ ] Add role guard dependency
* [ ] Add audit log on login
* [ ] Add tests/manual test steps

Acceptance criteria:

* User can login.
* Invalid user cannot login.
* Protected endpoint requires token.
* Role guard works.
* Password is not plain text.

## 11. Phase 5 — User and Admin Management

Goal: Admin can create and manage users.

Claude Code prompt:

```text
Implement Phase 5: User and Admin Management.

Scope:
- Backend only.
- Admin can create users with roles.
- Admin can activate/deactivate users.
- Admin can list users.
- Admin can update user role/status.
- Add audit logs for sensitive changes.

Endpoints:
- GET /api/v1/admin/users
- POST /api/v1/admin/users
- PUT /api/v1/admin/users/{userId}
- POST /api/v1/admin/users/{userId}/deactivate
- GET /api/v1/admin/roles

RBAC:
- Admin only.
```

TODO:

* [ ] User create schema
* [ ] User update schema
* [ ] Admin user routes
* [ ] Role assignment logic
* [ ] User status handling
* [ ] Duplicate email/phone validation
* [ ] Audit logs
* [ ] Tests/manual test steps

Acceptance criteria:

* Admin can create user.
* Duplicate email rejected.
* Non-admin cannot manage users.
* Audit log is created.

## 12. Phase 6 — Patient Profile Module

Goal: Create patient records and assign doctors/family.

Claude Code prompt:

```text
Implement Phase 6: Patient Profile Module.

Scope:
- Backend only.
- Create patient profile model, schemas, routes, and service.
- Link patient to user account.
- Assign patient to doctor.
- Link family member to patient.
- Enforce RBAC.

Endpoints:
- GET /api/v1/patients
- POST /api/v1/patients
- GET /api/v1/patients/{patientId}
- PUT /api/v1/patients/{patientId}
- POST /api/v1/patients/{patientId}/assign-doctor
- POST /api/v1/patients/{patientId}/family-members
- GET /api/v1/patients/{patientId}/timeline

Access:
- Doctor sees assigned patients only.
- Family sees linked patient only.
- Admin sees all.
- Manager sees center patients.
```

TODO:

* [ ] Patients model
* [ ] Doctors model
* [ ] FamilyMembers model
* [ ] Patient schemas
* [ ] Patient service
* [ ] Patient routes
* [ ] Doctor assignment
* [ ] Family linking
* [ ] RBAC filters
* [ ] Audit logs
* [ ] Tests/manual test steps

Acceptance criteria:

* Patient profile can be created.
* Doctor assignment works.
* Family link works.
* Unauthorized users cannot access unrelated patients.

## 13. Phase 7 — Mobile App Foundation

Goal: Create Flutter app foundation.

Claude Code prompt:

```text
Implement Phase 7: Flutter Mobile Foundation.

Scope:
- Mobile app only.
- Create clean Flutter architecture.
- Add routing.
- Add theme.
- Add Arabic/English localization structure.
- Add auth API client placeholder.
- Add secure token storage.
- Add login screen connected to backend if backend is ready.

Do not build all screens yet.
```

TODO:

* [ ] Flutter folder structure
* [ ] App routing
* [ ] Theme
* [ ] Large-button elderly-friendly UI style
* [ ] Localization files English/Arabic
* [ ] RTL support
* [ ] API client
* [ ] Secure storage
* [ ] Login screen
* [ ] Auth state
* [ ] Manual test on emulator/browser

Acceptance criteria:

* Flutter app runs.
* Login UI exists.
* Language structure exists.
* Arabic RTL is supported.
* Token can be stored securely.

## 14. Phase 8 — Patient Mobile Home

Goal: Patient can see simple home screen.

Claude Code prompt:

```text
Implement Phase 8: Patient Mobile Home.

Scope:
- Mobile app plus backend endpoints only if needed.
- Build patient home screen after login.
- Show:
  - welcome message
  - today’s therapy session placeholder
  - reminders placeholder
  - progress shortcut
  - games shortcut
  - language switch
  - logout

UI must be elderly-friendly:
- large buttons
- simple labels
- high contrast
- minimal clutter
```

TODO:

* [ ] Patient home screen
* [ ] Navigation cards
* [ ] Logout button
* [ ] Language switch
* [ ] Placeholder loading/error states
* [ ] Connect to `/auth/me`
* [ ] Manual test

Acceptance criteria:

* Patient logs in and reaches patient home.
* UI is simple and readable.
* Logout works.

## 15. Phase 9 — Cognitive Games Backend

Goal: Store game definitions and results.

Claude Code prompt:

```text
Implement Phase 9: Cognitive Games Backend.

Scope:
- Backend only.
- Create cognitive game definitions.
- Create game result tracking.
- Track score, max score, completion time, response time, mistakes, skipped count, difficulty, and result_json.

Endpoints:
- GET /api/v1/games
- GET /api/v1/games/{gameId}
- POST /api/v1/games
- PUT /api/v1/games/{gameId}
- POST /api/v1/games/{gameId}/start
- POST /api/v1/games/{gameId}/submit-result

Access:
- Patient can list and play active games.
- Admin can create/update games.
- Doctor can view results for assigned patients.
```

TODO:

* [ ] CognitiveGames model
* [ ] GameResults model
* [ ] Game schemas
* [ ] Game service
* [ ] Game routes
* [ ] Result validation
* [ ] Seed 3 game definitions
* [ ] RBAC
* [ ] Tests/manual test steps

Acceptance criteria:

* Admin can create game.
* Patient can see active games.
* Patient can submit result.
* Result is saved with metrics.

## 16. Phase 10 — Cognitive Games Mobile

Goal: Build three simple playable games.

Claude Code prompt:

```text
Implement Phase 10: Cognitive Games Mobile.

Scope:
- Flutter mobile only, with backend integration if available.
- Build 3 simple MVP games:
  1. Memory card matching
  2. Number sequence recall
  3. Attention target selection

Each game must track:
- score
- mistakes
- skipped tasks
- completion time
- average response time
- difficulty level

Submit result to backend.
```

TODO:

* [ ] Games list screen
* [ ] Memory card game
* [ ] Number sequence game
* [ ] Attention target game
* [ ] Result calculation
* [ ] Submit result API
* [ ] Success/failure state
* [ ] Arabic/English labels
* [ ] Manual test

Acceptance criteria:

* Patient can play 3 games.
* Result is calculated.
* Result is submitted to backend.
* UI remains simple and accessible.

## 17. Phase 11 — Cognitive Assessment

Goal: Add basic assessment flow.

Claude Code prompt:

```text
Implement Phase 11: Cognitive Assessment.

Scope:
- Backend and mobile.
- Add basic cognitive assessment tasks:
  - memory recall
  - attention
  - sequencing
  - simple matching

Backend endpoints:
- POST /api/v1/assessments/start
- POST /api/v1/assessments/submit
- GET /api/v1/assessments/patient/{patientId}
- GET /api/v1/assessments/{assessmentId}

Track:
- score
- mistakes
- skipped tasks
- average response time
- result_json
```

TODO:

* [ ] Assessment model
* [ ] Assessment endpoints
* [ ] Mobile assessment screen
* [ ] Result calculation
* [ ] Submit result
* [ ] Doctor view endpoint
* [ ] RBAC
* [ ] Manual test

Acceptance criteria:

* Patient can complete assessment.
* Result is saved.
* Doctor can view assigned patient result.

## 18. Phase 12 — Therapy Plan Management

Goal: Doctors create therapy plans and sessions.

Claude Code prompt:

```text
Implement Phase 12: Therapy Plan Management.

Scope:
- Backend first.
- Add therapy plans and therapy sessions.
- Doctor can create/update/pause/complete plan.
- Doctor can activate plan.
- Patient can view active sessions.

Endpoints:
- GET /api/v1/therapy-plans/patient/{patientId}
- POST /api/v1/therapy-plans
- GET /api/v1/therapy-plans/{planId}
- PUT /api/v1/therapy-plans/{planId}
- POST /api/v1/therapy-plans/{planId}/activate
- POST /api/v1/therapy-plans/{planId}/pause
- POST /api/v1/therapy-plans/{planId}/complete
```

TODO:

* [ ] TherapyPlans model
* [ ] TherapySessions model
* [ ] Therapy schemas
* [ ] Therapy service
* [ ] Therapy routes
* [ ] Doctor RBAC
* [ ] Patient active session access
* [ ] Audit logs
* [ ] Tests/manual test steps

Acceptance criteria:

* Doctor can create therapy plan.
* Plan can be activated.
* Patient can see active session.
* Unauthorized users are blocked.

## 19. Phase 13 — Doctor Web Dashboard Foundation

Goal: Start web dashboard for doctors.

Claude Code prompt:

```text
Implement Phase 13: Doctor Web Dashboard Foundation.

Scope:
- Web dashboard only, plus backend endpoint fixes if required.
- Create login page or connect existing login.
- Create doctor dashboard page.
- Show:
  - assigned patients
  - recent results
  - pending AI reviews placeholder
  - alerts placeholder
  - patient details navigation

Use clean table/card layout.
```

TODO:

* [ ] Web project setup
* [ ] Auth login page
* [ ] API client
* [ ] Token storage
* [ ] Doctor route guard
* [ ] Doctor dashboard page
* [ ] Assigned patients table
* [ ] Patient details link
* [ ] Manual test

Acceptance criteria:

* Doctor can login.
* Doctor sees assigned patients.
* Doctor cannot access admin routes.

## 20. Phase 14 — Family Dashboard

Goal: Family can monitor linked patient only.

Claude Code prompt:

```text
Implement Phase 14: Family Dashboard.

Scope:
- Backend and mobile.
- Family member can view linked patients.
- Family can view simplified progress, reminders, and alerts.
- Family must not see full medical notes unless explicitly allowed.

Endpoints:
- GET /api/v1/family/patients
- GET /api/v1/family/patients/{patientId}/summary
- GET /api/v1/family/patients/{patientId}/reminders
- GET /api/v1/family/alerts
```

TODO:

* [ ] Family backend routes
* [ ] Privacy filtering
* [ ] Family mobile home
* [ ] Linked patients list
* [ ] Simplified progress screen
* [ ] Reminder screen
* [ ] Alert screen
* [ ] RBAC tests/manual test

Acceptance criteria:

* Family sees only linked patient.
* Family cannot access unrelated patient.
* Summary is simplified.

## 21. Phase 15 — AI Recommendation Module

Goal: Add safe rule-based AI support.

Claude Code prompt:

```text
Implement Phase 15: AI Recommendation Module.

Scope:
- Backend only first.
- Implement rule-based therapy recommendation engine.
- Do not use real medical diagnosis.
- Use recent patient game results and assessments.
- Generate:
  - suggested games
  - difficulty
  - duration
  - reasoning
  - doctor attention items
  - disclaimer

Endpoints:
- POST /api/v1/ai/therapy-recommendation
- POST /api/v1/ai/recommendation/{id}/approve
- POST /api/v1/ai/recommendation/{id}/reject
- POST /api/v1/ai/recommendation/{id}/edit

Rules:
- Recommendation status starts as pending.
- Only doctor/therapist can approve/edit/reject.
- Approved recommendation can become therapy plan/session.
- Add audit logs.
- Include required medical disclaimer.
```

TODO:

* [ ] AIRecommendation model
* [ ] Rule-based engine
* [ ] Recommendation endpoint
* [ ] Safety disclaimer
* [ ] Pending status
* [ ] Approve endpoint
* [ ] Reject endpoint
* [ ] Edit endpoint
* [ ] Audit logs
* [ ] Tests/manual test steps

Acceptance criteria:

* Doctor can generate recommendation.
* Recommendation is non-diagnostic.
* Recommendation remains pending.
* Doctor can approve/edit/reject.
* Audit log is created.

## 22. Phase 16 — AI Progress Summary

Goal: Generate safe doctor-reviewable progress summary.

Claude Code prompt:

```text
Implement Phase 16: AI Progress Summary.

Scope:
- Backend only first.
- Generate progress summary using template-based text or safe LLM placeholder.
- Summary must be non-diagnostic.
- Summary must include:
  - sessions completed
  - sessions missed
  - score trend
  - response time trend
  - main difficulty areas
  - neutral recommendation
  - required disclaimer

Endpoint:
- POST /api/v1/ai/progress-summary
```

TODO:

* [ ] Progress summary service
* [ ] Safe wording rules
* [ ] Endpoint
* [ ] Doctor-only RBAC
* [ ] Store summary draft if needed
* [ ] Audit log
* [ ] Tests/manual test

Acceptance criteria:

* Summary generated.
* No diagnostic language.
* Doctor review status is included.
* Disclaimer is included.

## 23. Phase 17 — Progress Analytics

Goal: Show trends over time.

Claude Code prompt:

```text
Implement Phase 17: Progress Analytics.

Scope:
- Backend and dashboard/mobile as needed.
- Calculate:
  - average score by week/month
  - response time trend
  - mistakes trend
  - skipped tasks trend
  - adherence rate
  - completed vs missed sessions

Backend endpoint:
- GET /api/v1/doctor/patients/{patientId}/progress

Mobile:
- Patient can view simple personal progress.

Web:
- Doctor can view detailed assigned patient progress.
```

TODO:

* [ ] Analytics service
* [ ] Progress endpoint
* [ ] Patient progress mobile screen
* [ ] Doctor progress web screen
* [ ] Charts
* [ ] Empty states
* [ ] RBAC
* [ ] Manual test

Acceptance criteria:

* Doctor sees patient progress charts.
* Patient sees simple own progress.
* Family sees simplified progress only.
* No unauthorized access.

## 24. Phase 18 — Reminders and Notifications

Goal: Add medication, appointment, and therapy reminders.

Claude Code prompt:

```text
Implement Phase 18: Reminders and Notifications.

Scope:
- Backend first.
- Implement reminders table and in-app notifications.
- Push notification can be placeholder if FCM is not configured.
- Add scheduling structure.

Endpoints:
- POST /api/v1/reminders
- GET /api/v1/reminders/patient/{patientId}
- PUT /api/v1/reminders/{reminderId}
- DELETE /api/v1/reminders/{reminderId}
- GET /api/v1/notifications
- POST /api/v1/notifications/{id}/read
- POST /api/v1/notifications/register-device

Reminder types:
- medication
- appointment
- therapy
```

TODO:

* [ ] Reminders model
* [ ] Notifications model
* [ ] Reminder routes
* [ ] Notification routes
* [ ] In-app notification logic
* [ ] Device token registration
* [ ] Scheduler placeholder
* [ ] Failed notification handling
* [ ] Audit logs where needed
* [ ] Manual test

Acceptance criteria:

* Reminder can be created.
* Notification record can be created/read.
* Patient/family/doctor access is controlled.
* System does not crash on failed notification.

## 25. Phase 19 — PDF Reports

Goal: Generate downloadable progress reports.

Claude Code prompt:

```text
Implement Phase 19: PDF Reports.

Scope:
- Backend first.
- Generate PDF report for authorized doctor/admin/manager.
- Include:
  - patient basic info
  - date range
  - assessment results
  - game results
  - therapy session summary
  - reviewed AI summary only if available
  - disclaimer
  - generated by
  - generated date

Endpoints:
- POST /api/v1/reports/generate
- GET /api/v1/reports/patient/{patientId}
- GET /api/v1/reports/{reportId}
- GET /api/v1/reports/{reportId}/download

Add audit log for report generation/download.
```

TODO:

* [ ] Reports model
* [ ] Files model if not done
* [ ] PDF generation service
* [ ] Report routes
* [ ] Store PDF metadata
* [ ] Download endpoint
* [ ] RBAC
* [ ] Audit logs
* [ ] Manual test

Acceptance criteria:

* Authorized doctor/admin can generate PDF.
* Unauthorized user cannot download it.
* PDF includes disclaimer.
* Audit log is created.

## 26. Phase 20 — Admin and Manager Dashboard

Goal: Add admin/manager web features.

Claude Code prompt:

```text
Implement Phase 20: Admin and Manager Dashboard.

Scope:
- Web dashboard and backend fixes if needed.
- Admin pages:
  - users
  - roles
  - medical centers
  - audit logs

Manager pages:
  - center patients
  - center staff
  - center summary reports

RBAC:
- Admin can access full admin area.
- Manager can access center-level area only.
```

TODO:

* [ ] Admin route guard
* [ ] Manager route guard
* [ ] Users page
* [ ] Roles page
* [ ] Medical centers page
* [ ] Audit logs page
* [ ] Center summary page
* [ ] Manual test

Acceptance criteria:

* Admin can manage system data.
* Manager sees only center-level data.
* Non-admin cannot access admin pages.

## 27. Phase 21 — File Upload and Optional Voice Module

Goal: Add patient file upload and optional voice indicators.

Claude Code prompt:

```text
Implement Phase 21: File Upload and Optional Voice Module.

Scope:
- Implement file upload first.
- Voice analysis is optional/advanced.
- Store files outside database.
- Store metadata in database.

Endpoints:
- POST /api/v1/files/upload
- GET /api/v1/files/patient/{patientId}
- POST /api/v1/voice/upload
- POST /api/v1/voice/analyze
- GET /api/v1/voice/patient/{patientId}

Voice safety:
- Extract only basic measurable indicators.
- Do not diagnose.
- Include disclaimer.
```

TODO:

* [ ] File upload service
* [ ] File metadata model
* [ ] File access control
* [ ] Voice upload placeholder
* [ ] Basic voice indicator model
* [ ] Non-diagnostic disclaimer
* [ ] Manual test

Acceptance criteria:

* Authorized user can upload patient file.
* Unauthorized user cannot access file.
* Voice module does not diagnose.

## 28. Phase 22 — Localization and Accessibility Polish

Goal: Make app usable for Arabic/English and elderly users.

Claude Code prompt:

```text
Implement Phase 22: Localization and Accessibility Polish.

Scope:
- Mobile app and web dashboard.
- Ensure Arabic and English labels.
- Ensure RTL for Arabic.
- Improve patient UI accessibility.

Check:
- large buttons
- readable fonts
- high contrast
- simple navigation
- clear error messages
- no crowded screens
```

TODO:

* [ ] Arabic translations
* [ ] English translations
* [ ] RTL layout test
* [ ] Large buttons
* [ ] Accessible forms
* [ ] Empty states
* [ ] Error states
* [ ] Loading states
* [ ] Manual UI checklist

Acceptance criteria:

* User can switch language.
* Arabic displays RTL.
* Patient UI is simple and readable.

## 29. Phase 23 — Security and Privacy Review

Goal: Fix security gaps before demo.

Claude Code prompt:

```text
Implement Phase 23: Security and Privacy Review.

Scope:
- Review backend, mobile, and web.
- Do not add new features.
- Focus on:
  - RBAC
  - patient data privacy
  - password hashing
  - JWT protection
  - audit logs
  - input validation
  - file access
  - AI safety wording
  - environment secrets

Produce a security checklist and fix critical issues.
```

TODO:

* [ ] Check protected endpoints
* [ ] Check role guards
* [ ] Check patient ownership filters
* [ ] Check family linked-patient filter
* [ ] Check doctor assigned-patient filter
* [ ] Check password hashing
* [ ] Check secrets are not committed
* [ ] Check audit logs
* [ ] Check AI safety wording
* [ ] Check file access
* [ ] Fix issues
* [ ] Document remaining risks

Acceptance criteria:

* No obvious cross-patient access.
* No plain-text passwords.
* Sensitive actions are auditable.
* No diagnostic AI language.

## 30. Phase 24 — Testing and Demo Data

Goal: Prepare project for academic demo.

Claude Code prompt:

```text
Implement Phase 24: Testing and Demo Data.

Scope:
- Add seed/demo data.
- Add manual testing guide.
- Add demo accounts.
- Add test data for:
  - one patient
  - one family member
  - one doctor
  - one admin
  - one manager
  - several game results
  - one therapy plan
  - one AI recommendation
  - one report

Do not use real patient data.
```

TODO:

* [ ] Seed roles
* [ ] Seed demo users
* [ ] Seed medical center
* [ ] Seed patient profile
* [ ] Seed family link
* [ ] Seed doctor assignment
* [ ] Seed games
* [ ] Seed game results
* [ ] Seed therapy plan
* [ ] Seed AI recommendation
* [ ] Seed reminders
* [ ] Add demo credentials to local docs only
* [ ] Add manual testing guide

Acceptance criteria:

* Demo can run without manual database entry.
* All roles can be demonstrated.
* No real patient data used.

## 31. Phase 25 — Final Integration

Goal: Connect all parts together.

Claude Code prompt:

```text
Implement Phase 25: Final Integration.

Scope:
- Connect backend, mobile, and web dashboard.
- Fix integration bugs.
- Do not add major new features.
- Ensure the main demo flow works.

Demo flow:
1. Admin creates users.
2. Doctor sees assigned patient.
3. Patient logs in.
4. Patient plays game.
5. Result is saved.
6. Doctor views progress.
7. Doctor generates AI recommendation.
8. Doctor approves/edits recommendation.
9. Therapy plan appears.
10. Reminder appears.
11. PDF report is generated.
12. Audit logs show sensitive actions.
```

TODO:

* [ ] Backend runs
* [ ] Mobile runs
* [ ] Web runs
* [ ] Login works for all roles
* [ ] Patient game flow works
* [ ] Doctor progress flow works
* [ ] AI review flow works
* [ ] Reminder flow works
* [ ] Report flow works
* [ ] Audit log flow works
* [ ] Fix integration bugs

Acceptance criteria:

* Main demo flow works end-to-end.
* No blocking runtime errors.
* Project is presentable.

## 32. Phase 26 — Deployment Preparation

Goal: Prepare deployment or local demo environment.

Claude Code prompt:

```text
Implement Phase 26: Deployment Preparation.

Scope:
- Prepare Docker/local deployment files.
- Add environment documentation.
- Add production-like config examples.
- Do not expose secrets.

Include:
- backend run command
- mobile run command
- web run command
- database setup
- migration command
- seed command
- troubleshooting section
```

TODO:

* [ ] Docker compose for backend/database if possible
* [ ] Environment variable docs
* [ ] Migration docs
* [ ] Seed docs
* [ ] Backend deployment notes
* [ ] Web deployment notes
* [ ] Mobile build notes
* [ ] Troubleshooting notes

Acceptance criteria:

* Another student can run the system from README.
* No secrets committed.
* Demo setup is clear.

## 33. Phase 27 — Final Documentation

Goal: Prepare final academic documentation.

Claude Code prompt:

```text
Implement Phase 27: Final Documentation.

Scope:
- Documentation only.
- Create or update:
  - README.md
  - API_CONTRACT.md
  - DATABASE_SCHEMA.md
  - DEMO_SCRIPT.md
  - TESTING_GUIDE.md
  - SECURITY_AND_PRIVACY.md
  - AI_SAFETY.md

Keep documentation clear and suitable for final-year project evaluation.
```

TODO:

* [ ] README updated
* [ ] API contract documented
* [ ] Database schema documented
* [ ] Demo script written
* [ ] Testing guide written
* [ ] Security/privacy notes written
* [ ] AI safety notes written
* [ ] Known limitations written
* [ ] Future enhancements written

Acceptance criteria:

* Documentation is complete.
* Supervisor/examiner can understand the project.
* Demo script is ready.

## 34. Recommended Claude Code Starting Command

After saving this document, start Claude Code with this prompt:

```text
Read CLAUDE.md and PROJECT_EXECUTION_PLAN.md.

Start Phase 0 only.

Do not edit files yet.
Inspect the repository and tell me:
1. current structure
2. what exists
3. what is missing
4. what commands are available
5. the safest next step
```

## 35. Important Working Rule

Never ask Claude Code to:

```text
Build the whole NeuroBridge system.
```

Always ask:

```text
Implement Phase X only.
```

or:

```text
Implement this one task from Phase X only.
```

This project is complex. The correct strategy is:

Foundation → Backend → Database → Auth/RBAC → Patient Module → Mobile Login → Games → Therapy → Doctor Dashboard → AI Review → Reports → Notifications → Polish → Demo.

## 36. Final MVP Priority Order

If time is limited, implement only this MVP order:

1. Backend skeleton
2. Database
3. Auth and RBAC
4. Admin user creation
5. Patient profile
6. Doctor assignment
7. Flutter login
8. Patient home
9. Cognitive games
10. Game result tracking
11. Doctor dashboard
12. Therapy plan
13. AI recommendation with doctor review
14. Progress analytics
15. PDF report
16. Audit logs
17. Arabic/English polish

Optional later:

* Voice analysis
* Tele-rehabilitation
* Wearable integration
* Offline synchronization
* Hospital system integration
* Advanced AI model

## 37. Final Instruction to Claude Code

Follow the phases in order.
Do not skip foundation work.
Do not overbuild optional features.
Do not generate diagnostic medical claims.
Keep the project clean, testable, and demo-ready.
