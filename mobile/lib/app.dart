import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/app_scope.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_controller.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/application/auth_controller.dart';
import 'features/encouragements/application/encouragement_controller.dart';
import 'features/games/application/game_result_controller.dart';
import 'features/games/application/games_controller.dart';
import 'features/home/application/home_controller.dart';
import 'features/memories/application/memories_controller.dart';
import 'features/profile/application/profile_controller.dart';
import 'features/progress/application/progress_controller.dart';
import 'routes/app_router.dart';

/// Root application widget. Wires theme, localization (with RTL for Arabic),
/// routing, and the app-wide controllers.
class NeuroBridgeApp extends StatefulWidget {
  const NeuroBridgeApp({
    super.key,
    required this.auth,
    required this.locale,
    required this.home,
    required this.games,
    required this.gameResults,
    required this.progress,
    required this.profile,
    required this.memories,
    this.encouragements,
  });

  final AuthController auth;
  final LocaleController locale;
  final HomeController home;
  final GamesController games;
  final GameResultController gameResults;
  final ProgressController progress;
  final ProfileController profile;
  final MemoriesController memories;
  final EncouragementController? encouragements;

  @override
  State<NeuroBridgeApp> createState() => _NeuroBridgeAppState();
}

class _NeuroBridgeAppState extends State<NeuroBridgeApp> {
  late final GoRouter _router = createRouter(widget.auth);

  @override
  Widget build(BuildContext context) {
    return AppScope(
      auth: widget.auth,
      locale: widget.locale,
      home: widget.home,
      games: widget.games,
      gameResults: widget.gameResults,
      progress: widget.progress,
      profile: widget.profile,
      memories: widget.memories,
      encouragements: widget.encouragements,
      child: ListenableBuilder(
        listenable: widget.locale,
        builder: (context, _) {
          return MaterialApp.router(
            title: 'NeuroBridge',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            locale: widget.locale.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
