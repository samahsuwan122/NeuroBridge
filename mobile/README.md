# NeuroBridge Mobile App

The mobile app is built with **Flutter (Dart)**. It is **mobile-first** and is the **only** client
for patients and their families/caregivers.

> This app is for **Patient** and **Family / caregiver** users only.
> Clinical and administrative roles (doctor, therapist, admin, manager) use the **web dashboard**
> instead — see [`../web/README.md`](../web/README.md). There is **no patient web dashboard**.

As of **Phase 10**, the app has a clean foundation (routing, theme, Arabic/English localization with
RTL, secure token store, Dio API client, backend-wired login), a **patient/family home screen**, and
a **cognitive games list**: the home "Cognitive Games" card opens a **Games screen** that loads active
games from `GET /api/v1/games` (with safe loading/empty/error states) and shows large elderly-friendly
game cards; tapping one opens a **Game details placeholder** (metadata + "Game play will be added in a
later phase."). Other home cards remain **"Coming soon"**. No real game mechanics or result submission
yet.

## Project structure

```text
mobile/
  pubspec.yaml
  lib/
    main.dart                     # bootstrap + dependency wiring
    app.dart                      # MaterialApp.router + theme + localization
    core/
      app_scope.dart              # exposes auth + locale + home controllers
      config/app_config.dart      # configurable backend base URL
      network/api_client.dart     # Dio wrapper
      storage/secure_storage_service.dart
      theme/app_colors.dart          # medical-luxury palette constants
      theme/app_theme.dart           # premium M3 light theme (emerald/ivory/sage/gold)
      localization/app_localizations.dart   # en/ar strings + delegate
      localization/locale_controller.dart
      widgets/language_button.dart
      widgets/dashboard_card.dart  # large elderly-friendly card
      widgets/loading_state.dart
      widgets/error_state.dart
    features/
      auth/
        data/{auth_api,auth_repository,auth_user}.dart
        application/auth_controller.dart
        presentation/login_screen.dart
      home/
        data/{patient_api,patient_profile_summary}.dart
        application/home_controller.dart
        presentation/home_screen.dart
      games/
        data/{games_api,game_definition,memory_card,game_results_api}.dart
        application/{games_controller,memory_match_controller,game_result_controller}.dart
        presentation/{games_screen,game_details_screen,memory_match_screen}.dart
      progress/
        data/{progress_api,game_result_summary}.dart
        application/progress_controller.dart
        presentation/progress_screen.dart
      profile/
        data/{profile_api,patient_profile_detail}.dart
        application/profile_controller.dart
        presentation/profile_screen.dart
    routes/app_router.dart        # /login /home /games /games/details
                                  # /games/play/memory-match /progress /profile
```

The home **My Profile** card opens a **read-only Profile screen** (`/profile`) that shows the
patient's own basic fields from `GET /api/v1/patients` (first profile): full name, email, phone, date
of birth, gender, emergency contact, and member-since — each with a **"Not provided"** fallback. It
also shows a read-only **Care & Safety Information** section (allergies, current medications, blood
type, mobility needs, vision/hearing needs, preferred communication, caregiver notes) with a
"care/safety only, not a diagnosis" note. It deliberately omits `medical_center_id`, `notes`, and
anything diagnostic. Safe loading/empty/error+retry states; no editing in this phase.

The home **Progress** card opens a **Progress screen** (`/progress`) that lists the patient's saved
results from `GET /api/v1/games/results`, joined with `GET /api/v1/games` for game titles (fallback to
id). Each card shows game title, score/max, duration, completed, date, and moves/mistakes — **game
performance only**, not a medical assessment. Safe loading/empty/error+retry states; no charts.

**Memory Match** is the first playable exercise. Its details screen shows a **Play** button; other
games still show "Game play will be added in a later phase." On completion the result is
**auto-submitted once** to `POST /api/v1/games/{id}/results` (with a Saving/Saved/Retry status), and
scores are **game performance only** (score=matched pairs, metrics=moves/mistakes/matched/total) — no
medical interpretation. Submission is skipped gracefully if the game id is unavailable.

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

## Theme

The app uses a premium **"medical luxury"** Material 3 **light** theme (`core/theme/`): deep
emerald/dark-teal primary, ivory/warm-white backgrounds, muted sage, and champagne-gold **accents
only** (chips/borders/icons — never body text, to preserve contrast). Rounded cards with soft
shadows, 56px emerald buttons, rounded inputs, and slightly larger readable typography.

Shared premium building blocks live in `core/widgets/`: `EmeraldPanel` (deep-emerald gradient hero),
`IconChip`, and `SectionHeader`. These give a **hero login**, an **emerald welcome card** on Home,
icon-chip game/result cards, richer Memory Match tiles + a gradient completion header, and
icon-chip section headers on the Profile screen. Styling only — no behavior or medical logic changes.

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
