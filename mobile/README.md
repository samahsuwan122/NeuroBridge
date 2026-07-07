# NeuroBridge Mobile App

The mobile app is built with **Flutter (Dart)**. It is **mobile-first** and is the **only** client
for patients and their families/caregivers.

> This app is for **Patient** and **Family / caregiver** users only.
> Clinical and administrative roles (doctor, therapist, admin, manager) use the **web dashboard**
> instead — see [`../web/README.md`](../web/README.md). There is **no patient web dashboard**.

In Phase 1 this folder is **foundation only** (this README). The Flutter project is scaffolded in a
later phase per [`../PROJECT_EXECUTION_PLAN.md`](../PROJECT_EXECUTION_PLAN.md).

## Patient features (planned)

- Login
- Patient home
- Cognitive games
- Cognitive assessment
- Therapy sessions
- Reminders
- Progress
- Notifications
- Arabic / English language switch

## Family / caregiver features (planned)

- Linked patients
- Simplified progress
- Reminders
- Alerts

## Localization & accessibility

- **Arabic 🇸🇦 and English 🇬🇧** are both supported.
- **Right-to-left (RTL)** layout is fully supported for Arabic.
- The patient experience is designed to be **elderly-friendly**: large buttons, simple labels,
  high contrast, simple navigation, and minimal on-screen clutter.

## Commands (activated when the Flutter project is scaffolded)

```bash
cd mobile
flutter pub get
flutter run
```

## Safety reminder

NeuroBridge is **not a diagnostic medical system**. No screen or message may claim to diagnose any
condition. AI output shown to users is always a non-diagnostic support recommendation pending
doctor/therapist review. See [`../CLAUDE.md`](../CLAUDE.md).
