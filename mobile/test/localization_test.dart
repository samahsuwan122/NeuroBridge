import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neurobridge_mobile/core/app_scope.dart';
import 'package:neurobridge_mobile/core/localization/app_localizations.dart';
import 'package:neurobridge_mobile/core/localization/locale_controller.dart';
import 'package:neurobridge_mobile/core/network/api_client.dart';
import 'package:neurobridge_mobile/core/storage/secure_storage_service.dart';
import 'package:neurobridge_mobile/core/widgets/language_button.dart';
import 'package:neurobridge_mobile/features/auth/application/auth_controller.dart';
import 'package:neurobridge_mobile/features/auth/data/auth_api.dart';
import 'package:neurobridge_mobile/features/auth/data/auth_repository.dart';
import 'package:neurobridge_mobile/features/games/application/game_result_controller.dart';
import 'package:neurobridge_mobile/features/games/application/games_controller.dart';
import 'package:neurobridge_mobile/features/games/data/game_results_api.dart';
import 'package:neurobridge_mobile/features/games/data/games_api.dart';
import 'package:neurobridge_mobile/features/home/application/home_controller.dart';
import 'package:neurobridge_mobile/features/home/data/patient_api.dart';
import 'package:neurobridge_mobile/features/memories/application/memories_controller.dart';
import 'package:neurobridge_mobile/features/memories/data/memories_api.dart';
import 'package:neurobridge_mobile/features/profile/application/profile_controller.dart';
import 'package:neurobridge_mobile/features/profile/data/profile_api.dart';
import 'package:neurobridge_mobile/features/progress/application/progress_controller.dart';
import 'package:neurobridge_mobile/features/progress/data/progress_api.dart';

const _localizationsDelegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

// Expected "Cognitive Games" translation per language (a common visible label).
const _cognitiveGames = {
  'ar': 'الألعاب الإدراكية',
  'en': 'Cognitive Games',
  'fr': 'Jeux cognitifs',
  'es': 'Juegos cognitivos',
  'de': 'Kognitive Spiele',
  'tr': 'Bilişsel oyunlar',
  'pt': 'Jogos cognitivos',
  'it': 'Giochi cognitivi',
  'hi': 'संज्ञानात्मक खेल',
  'id': 'Permainan kognitif',
};

ApiClient _c() => ApiClient();

Future<LocaleController> _pumpLanguageButton(WidgetTester tester) async {
  // Tall viewport so the whole 10-item picker sheet builds in one screen.
  tester.view.physicalSize = const Size(1000, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final storage = SecureStorageService();
  final locale = LocaleController(const Locale('en'));
  await tester.pumpWidget(
    AppScope(
      auth: AuthController(AuthRepository(AuthApi(_c()), storage)),
      locale: locale,
      home: HomeController(PatientApi(_c()), storage),
      games: GamesController(GamesApi(_c()), storage),
      gameResults:
          GameResultController(GameResultsApi(_c()), PatientApi(_c()), storage),
      progress: ProgressController(ProgressApi(_c()), GamesApi(_c()), storage),
      profile: ProfileController(ProfileApi(_c()), storage),
      memories: MemoriesController(MemoriesApi(_c()), PatientApi(_c()), storage),
      child: MaterialApp(
        locale: locale.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: _localizationsDelegates,
        home: Scaffold(appBar: AppBar(actions: const [LanguageButton()])),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return locale;
}

void main() {
  test('supports 10 languages', () {
    expect(AppLocalizations.supportedLocales.length, 10);
    expect(AppLocalizations.supportedLanguages.length, 10);
    final codes =
        AppLocalizations.supportedLanguages.map((l) => l.code).toList();
    expect(codes, containsAll(
        ['ar', 'en', 'fr', 'es', 'de', 'tr', 'pt', 'it', 'hi', 'id']));
  });

  test('each language translates a common label', () {
    for (final entry in _cognitiveGames.entries) {
      final l10n = AppLocalizations(Locale(entry.key));
      expect(l10n.cognitiveGames, entry.value, reason: entry.key);
    }
  });

  test('missing keys fall back to English', () {
    // "savingResult" is not translated in French -> English fallback.
    expect(AppLocalizations(const Locale('fr')).savingResult,
        AppLocalizations(const Locale('en')).savingResult);
  });

  test('no locale introduces unsafe English medical wording', () {
    const banned = ['dementia', 'alzheimer', 'impairment', 'abnormal', 'disease'];
    for (final lang in AppLocalizations.supportedLanguages) {
      final l = AppLocalizations(Locale(lang.code));
      final notes = [
        l.careSafetyNote,
        l.memoryAlbumNote,
        l.progressAnalyticsNote,
        l.reactionTimeNote,
        l.attentionTapNote,
        l.sequenceRecallNote,
      ];
      for (final note in notes) {
        for (final bad in banned) {
          expect(note.toLowerCase().contains(bad), isFalse,
              reason: '${lang.code}: "$note"');
        }
      }
    }
  });

  // --- direction ---

  const directions = {
    'ar': TextDirection.rtl,
    'en': TextDirection.ltr,
    'fr': TextDirection.ltr,
    'es': TextDirection.ltr,
    'de': TextDirection.ltr,
    'tr': TextDirection.ltr,
    'pt': TextDirection.ltr,
    'it': TextDirection.ltr,
    'hi': TextDirection.ltr,
    'id': TextDirection.ltr,
  };

  directions.forEach((code, expected) {
    testWidgets('$code uses ${expected.name}', (tester) async {
      TextDirection? dir;
      await tester.pumpWidget(MaterialApp(
        locale: Locale(code),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: _localizationsDelegates,
        home: Builder(builder: (context) {
          dir = Directionality.of(context);
          return const SizedBox.shrink();
        }),
      ));
      await tester.pumpAndSettle(); // let localizations load and home build
      expect(dir, expected);
    });
  });

  // --- language picker ---

  testWidgets('language picker lists all 10 languages', (tester) async {
    await _pumpLanguageButton(tester);
    await tester.tap(find.byKey(const Key('language_button')));
    await tester.pumpAndSettle();
    for (final lang in AppLocalizations.supportedLanguages) {
      expect(find.text(lang.name), findsWidgets, reason: lang.code);
    }
  });

  testWidgets('selecting a language updates the controller', (tester) async {
    final locale = await _pumpLanguageButton(tester);
    await tester.tap(find.byKey(const Key('language_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('lang_fr')));
    await tester.pumpAndSettle();
    expect(locale.locale.languageCode, 'fr');
  });
}
