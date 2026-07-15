import 'package:flutter/widgets.dart';

import '../features/auth/application/auth_controller.dart';
import '../features/encouragements/application/encouragement_controller.dart';
import '../features/games/application/game_result_controller.dart';
import '../features/games/application/games_controller.dart';
import '../features/home/application/home_controller.dart';
import '../features/memories/application/memories_controller.dart';
import '../features/profile/application/profile_controller.dart';
import '../features/progress/application/progress_controller.dart';
import 'localization/locale_controller.dart';

/// Exposes the app-wide controllers to the tree.
class AppScope extends InheritedWidget {
  const AppScope({
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
    required super.child,
  });

  final AuthController auth;
  final LocaleController locale;
  final HomeController home;
  final GamesController games;
  final GameResultController gameResults;
  final ProgressController progress;
  final ProfileController profile;
  final MemoriesController memories;

  /// Optional: patient-facing family encouragements. Null in tests that do not
  /// exercise this feature (the home screen then hides the section).
  final EncouragementController? encouragements;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope was not found in the widget tree');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      auth != oldWidget.auth ||
      locale != oldWidget.locale ||
      home != oldWidget.home ||
      games != oldWidget.games ||
      gameResults != oldWidget.gameResults ||
      progress != oldWidget.progress ||
      profile != oldWidget.profile ||
      memories != oldWidget.memories ||
      encouragements != oldWidget.encouragements;
}
