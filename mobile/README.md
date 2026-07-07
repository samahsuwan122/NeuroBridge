# NeuroBridge Mobile App

The mobile app is built with **Flutter (Dart)**. It is **mobile-first** and is the **only** client
for patients and their families/caregivers.

> This app is for **Patient** and **Family / caregiver** users only.
> Clinical and administrative roles (doctor, therapist, admin, manager) use the **web dashboard**
> instead — see [`../web/README.md`](../web/README.md). There is **no patient web dashboard**.

As of **Phase 7**, the Flutter project is scaffolded with a clean foundation: routing, theme,
Arabic/English localization (RTL), a secure token store, a Dio API client, and a **login screen wired
to the backend** plus a logged-in **home placeholder** with logout. Patient/family features come in
later phases.

## Project structure (Phase 7)

```text
mobile/
  pubspec.yaml
  lib/
    main.dart                     # bootstrap + dependency wiring
    app.dart                      # MaterialApp.router + theme + localization
    core/
      app_scope.dart              # exposes auth + locale controllers to the tree
      config/app_config.dart      # configurable backend base URL
      network/api_client.dart     # Dio wrapper
      storage/secure_storage_service.dart
      theme/app_theme.dart
      localization/app_localizations.dart   # en/ar strings + delegate
      localization/locale_controller.dart
      widgets/language_button.dart
    features/
      auth/
        data/{auth_api,auth_repository,auth_user}.dart
        application/auth_controller.dart
        presentation/login_screen.dart
      home/
        presentation/home_screen.dart
    routes/app_router.dart        # go_router with auth redirect
```

## Running

Start the backend first (from `../backend`, with the venv active):

```powershell
uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

Then run the app:

```powershell
cd mobile
flutter pub get
flutter analyze
flutter test

# Web (dev): use port 3000 so it matches the backend's allowed CORS origins.
flutter run -d chrome --web-port=3000

# Android emulator (uses http://10.0.2.2:8000 automatically):
flutter run -d emulator-5554
```

The backend base URL is resolved in `lib/core/config/app_config.dart` (web → `127.0.0.1:8000`,
Android emulator → `10.0.2.2:8000`). Override with
`--dart-define=API_BASE_URL=http://<host>:8000`.

> **CORS note (web dev):** the backend allows `http://localhost:3000` and `http://localhost:5173`.
> Run Flutter web on `--web-port=3000` so browser login requests are not blocked by CORS. (No backend
> change is required.)

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

- **Arabic 🇸🇦 and English 🇬🇧** are both supported (see `core/localization/app_localizations.dart`).
- **Right-to-left (RTL)** layout is applied automatically for Arabic via `GlobalWidgetsLocalizations`.
  A language toggle in the app bar switches between English and Arabic at runtime.
- The patient experience is designed to be **elderly-friendly**: large buttons, simple labels,
  high contrast, simple navigation, and minimal on-screen clutter (expanded in later phases).

## Safety reminder

NeuroBridge is **not a diagnostic medical system**. No screen or message may claim to diagnose any
condition. AI output shown to users is always a non-diagnostic support recommendation pending
doctor/therapist review. See [`../CLAUDE.md`](../CLAUDE.md).
