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
        presentation/{games_screen,game_details_screen,memory_match_screen,game_visuals}.dart
        memory_recall/
          data/memory_recall_question.dart
          application/memory_recall_controller.dart
          presentation/memory_recall_screen.dart
        reaction_time/
          application/reaction_time_controller.dart
          presentation/reaction_time_screen.dart
        attention_tap/
          application/attention_tap_controller.dart
          presentation/attention_tap_screen.dart
        sequence_recall/
          application/sequence_recall_controller.dart
          presentation/sequence_recall_screen.dart
      progress/
        data/{progress_api,game_result_summary}.dart
        application/progress_controller.dart
        presentation/progress_screen.dart
      profile/
        data/{profile_api,patient_profile_detail}.dart
        application/profile_controller.dart
        presentation/profile_screen.dart
      memories/
        data/{memories_api,memory_entry,memory_image,memory_image_picker}.dart
        application/memories_controller.dart
        presentation/{memories_screen,memory_details_screen,memory_create_screen,memory_image_view}.dart
    routes/app_router.dart        # /login /home /games /games/details
                                  # /games/play/memory-match /progress /profile
                                  # /memories /memories/new /memories/details
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

The home **Memory Album** card opens a read-only **Memory Album** (`/memories`) that lists the
caller's visible memories from `GET /api/v1/memories` (role-scoped by the backend). Each card shows
the title, person/relationship, place, and category/media-type/date chips; tapping one opens a
**memory detail** screen (`/memories/details`) with the full fields. Memories are **supportive,
family-engagement content only** (a small note says they are "for family connection and supportive
recall activities only") — no diagnosis, scoring, or medical interpretation. `media_url` is shown as
placeholder text, not an image (no real upload yet). Safe loading/empty/error+retry states.

An **Add memory** button opens a form (`/memories/new`) where a patient/family/admin user can create
a memory via `POST /api/v1/memories` (title required; description, person, relationship, place,
memory date `YYYY-MM-DD`, category, media type, and a media-URL/placeholder text — all optional). The
target patient profile is resolved from the first visible `GET /api/v1/patients` profile; a missing
profile or backend error shows a friendly message.

The form also supports **real image upload** (via `image_picker`, mobile + web): a **Choose image**
button picks a JPEG/PNG/WebP up to 5 MB (validated client-side, with friendly type/size errors). On
save the app **creates the memory first** (`POST /memories`), then **uploads the image**
(`POST /memories/{id}/media`), and returns to the album on success. If the memory is created but the
image upload fails, the memory is kept and a friendly "you can add it later" message is shown. No
edit/delete UI yet; `MemoriesApi` sends the image as in-memory bytes so no local file path is logged.

Uploaded images are **displayed** across the album: `MemoryEntry.resolvedImageUrl(baseUrl)` turns the
backend's relative `media_url` (`/media/memory_uploads/<file>`) into a full URL (external `http(s)`
URLs are used as-is), and a reusable `MemoryImageView` renders it with rounded corners, a loading
spinner, and a graceful error placeholder. The list card shows a **rounded thumbnail** (falling back
to the icon chip when there is no image) alongside the "Image attached" chip; the details screen
shows a **large hero image** (or an elegant "No image attached" placeholder). Images are personal
memory content only — no analysis or interpretation.

**Memory Recall** is a personalized exercise built from the patient's Memory Album. From the game
details screen (game slug `memory_recall`) a **Start Memory Recall** button opens
`/games/play/memory-recall`. It loads the album via `GET /api/v1/memories` and generates safe
multiple-choice questions **only from entered fields** — "Who is this person?" (person), "Where was
this memory?" (place), "What category does this memory belong to?" (category) — using other entries
as distractors (nothing is inferred, no AI, no image analysis). Each question shows the memory's
image (or an elegant placeholder), gives immediate **Correct / Try again** feedback, and moves on;
a final summary shows the score. If there are too few usable memories it shows *"Add more memories to
start this exercise."* On completion it submits **game-performance-only** results via the existing
`POST /api/v1/games/{id}/results` with metrics `exercise_type=memory_recall`, `question_count`,
`correct_count`, `memory_entry_ids` — no diagnosis, scoring interpretation, or medical content.

**Sequence Recall** is a playable working-memory exercise (game slug `sequence_order`, route
`/games/play/sequence-order`). Each round reveals a growing sequence of colored tiles, then switches
to input mode where the user repeats it in order; a correct repeat advances, a wrong tap ends the
round as a mistake. After 5 rounds a summary shows **correct**, **mistakes**, **longest sequence**,
**accuracy %**, and **rounds**, submitted as **game performance only** via
`POST /api/v1/games/{id}/results` (`score` = correct sequences, `metrics = {exercise_type:
"sequence_recall", round_count, correct_count, mistake_count, longest_sequence, accuracy_percent}`).
Memory is never interpreted medically. The sequences come from an injectable `Random` and the reveal
`Timer` lives in the screen, so tests are deterministic (they drive the controller directly).

**Attention Tap** is a playable focus exercise (game slug `attention_focus`, route `/games/play/
attention-focus`). Each round shows a grid of icons; the current **target** icon is shown, and the
user taps the matching icon (a correct tap raises the correct count, any other tap is a mistake, and
every tap advances the round). After 10 rounds a summary shows **correct**, **mistakes**, **accuracy
%**, and **rounds completed**, submitted as **game performance only** via
`POST /api/v1/games/{id}/results` (`score` = correct taps, `metrics = {exercise_type:"attention_tap",
round_count, correct_count, mistake_count, accuracy_percent}`). Attention is never interpreted
medically. The grid/target come from an injectable `Random`, so tests are deterministic (no timers).

**Reaction Time** is a playable speed exercise (game slug `reaction_time`, route `/games/play/
reaction-time`). Each round shows "Wait…", then (after a random delay) "Tap now!"; the app measures
the tap-to-signal time in milliseconds (tapping early is a friendly "Too soon" and is not counted).
After 5 rounds a summary shows **best**, **average**, and **rounds completed**, and the result is
submitted as **game performance only** via `POST /api/v1/games/{id}/results` (`score` = rounds
completed, `metrics = {exercise_type:"reaction_time", round_count, best_reaction_ms,
average_reaction_ms, reaction_times_ms}`). Times are never interpreted medically (no normal/abnormal,
no diagnosis). Timing is testable: the controller is a pure state machine over an injectable clock and
the screen owns the round `Timer`.

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

A light **luxury polish pass** further refines the shared building blocks and high-impact screens:
the shared `LoadingState`/`ErrorState` are now centered and elegant (a tinted icon + a clear retry
button) so every screen's loading/empty/error states look consistent; Home gains an **"Activities"**
section header for clearer hierarchy; Game details groups its metadata/instructions in a premium
card; the Memory Album empty state is a friendly icon + message; and the Memory Recall summary uses
an emerald gradient header with a gold trophy chip. Login gains a gold title accent, and Progress /
Profile get elegant empty states with a sage-tinted care/safety note banner. The games list and
details use **per-game icons** (`game_visuals.dart`); the Add Memory image picker sits in an elegant
framed area; Memory Album thumbnails are subtly framed; the Memory Details description is its own
card; and the Memory Recall play view groups the question + options in a card with a progress pill.
All changes are **styling/layout only** — no behavior, navigation, API, or game-result logic changed.

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
