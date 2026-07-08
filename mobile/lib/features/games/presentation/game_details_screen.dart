import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/language_button.dart';
import '../data/game_definition.dart';

/// Placeholder game details. Shows metadata and a note that game play is added
/// in a later phase. No game mechanics here.
class GameDetailsScreen extends StatelessWidget {
  const GameDetailsScreen({super.key, this.game});

  final GameDefinition? game;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final game = this.game;

    return Scaffold(
      appBar: AppBar(
        title: Text(game?.name ?? l10n.gameDetails),
        actions: const [LanguageButton()],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: game == null
                  ? Text(l10n.noGamesAvailable)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(game.name, style: theme.textTheme.headlineSmall),
                        const SizedBox(height: 16),
                        _MetaRow(label: l10n.difficulty, value: game.difficulty),
                        if (game.estimatedDurationMinutes != null)
                          _MetaRow(
                            label: l10n.estimatedDuration,
                            value: '${game.estimatedDurationMinutes} ${l10n.minutes}',
                          ),
                        if ((game.instructions ?? '').isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(l10n.instructions,
                              style: theme.textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(game.instructions!),
                        ],
                        const SizedBox(height: 24),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline),
                                const SizedBox(width: 12),
                                Expanded(child: Text(l10n.gamePlayComingLater)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text('$label: $value'),
    );
  }
}
