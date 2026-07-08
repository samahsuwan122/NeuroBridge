import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_scope.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/language_button.dart';
import '../../../core/widgets/loading_state.dart';
import '../application/games_controller.dart';
import '../data/game_definition.dart';

/// Cognitive games list. Tapping a game opens a details placeholder — no real
/// game mechanics yet.
class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppScope.of(context).games.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final games = AppScope.of(context).games;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.gamesTitle),
        actions: const [LanguageButton()],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: AnimatedBuilder(
              animation: games,
              builder: (context, _) => _body(context, games, l10n),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    GamesController games,
    AppLocalizations l10n,
  ) {
    switch (games.status) {
      case GamesStatus.initial:
      case GamesStatus.loading:
        return Center(child: LoadingState(message: l10n.loadingGames));
      case GamesStatus.error:
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ErrorState(
            message: l10n.gamesLoadError,
            retryLabel: l10n.retry,
            onRetry: games.load,
          ),
        );
      case GamesStatus.empty:
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Center(child: Text(l10n.noGamesAvailable)),
        );
      case GamesStatus.loaded:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final game in games.games)
                _GameCard(
                  game: game,
                  l10n: l10n,
                  onTap: () => context.go('/games/details', extra: game),
                ),
            ],
          ),
        );
    }
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.game,
    required this.l10n,
    required this.onTap,
  });

  final GameDefinition game;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meta = <String>['${l10n.difficulty}: ${game.difficulty}'];
    if (game.estimatedDurationMinutes != null) {
      meta.add('${game.estimatedDurationMinutes} ${l10n.minutes}');
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.videogame_asset,
                  size: 28,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(game.name, style: theme.textTheme.titleLarge),
                    if ((game.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(game.description!, style: theme.textTheme.bodyMedium),
                    ],
                    const SizedBox(height: 6),
                    Text(meta.join('  ·  '), style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
