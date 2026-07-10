import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/emerald_panel.dart';
import '../../../core/widgets/language_button.dart';
import '../data/game_definition.dart';

const _memoryMatchSlug = 'memory_match';
const _memoryRecallSlug = 'memory_recall';

/// Game details. For playable games (Memory Match) it shows a Play button;
/// other games show a note that game play is added in a later phase.
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
                        Row(
                          children: [
                            const IconChip(
                                icon: Icons.videogame_asset_rounded, size: 56),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(game.name,
                                  style: theme.textTheme.headlineSmall),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _MetaRow(
                                    label: l10n.difficulty,
                                    value: game.difficulty),
                                if (game.estimatedDurationMinutes != null)
                                  _MetaRow(
                                    label: l10n.estimatedDuration,
                                    value:
                                        '${game.estimatedDurationMinutes} ${l10n.minutes}',
                                  ),
                                if ((game.instructions ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text(l10n.instructions,
                                      style: theme.textTheme.titleMedium),
                                  const SizedBox(height: 6),
                                  Text(game.instructions!),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (game.slug == _memoryMatchSlug)
                          FilledButton.icon(
                            onPressed: () => context.go(
                              '/games/play/memory-match',
                              extra: game,
                            ),
                            icon: const Icon(Icons.play_arrow),
                            label: Text(l10n.play),
                          )
                        else if (game.slug == _memoryRecallSlug)
                          FilledButton.icon(
                            onPressed: () => context.go(
                              '/games/play/memory-recall',
                              extra: game,
                            ),
                            icon: const Icon(Icons.play_arrow),
                            label: Text(l10n.startMemoryRecall),
                          )
                        else
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: Text(l10n.gamePlayComingLater)),
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
