import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/language_button.dart';
import '../application/memory_match_controller.dart';
import '../data/game_definition.dart';
import '../data/memory_card.dart';

/// Playable Memory Match exercise (mobile). Play-only — results are not
/// submitted to the backend, and scores are game performance only.
class MemoryMatchScreen extends StatefulWidget {
  const MemoryMatchScreen({super.key, this.game});

  final GameDefinition? game;

  @override
  State<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _MemoryMatchScreenState extends State<MemoryMatchScreen> {
  final MemoryMatchController _controller = MemoryMatchController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game?.name ?? 'Memory Match'),
        actions: const [LanguageButton()],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _StatsRow(controller: _controller, l10n: l10n),
                      const SizedBox(height: 12),
                      if (_controller.completed) ...[
                        _CompletionPanel(controller: _controller, l10n: l10n),
                        const SizedBox(height: 12),
                      ],
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.85,
                          children: [
                            for (var i = 0; i < _controller.cards.length; i++)
                              _CardTile(
                                card: _controller.cards[i],
                                onTap: () => _controller.flip(i),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.controller, required this.l10n});

  final MemoryMatchController controller;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _Stat(label: l10n.moves, value: '${controller.moves}'),
        _Stat(
          label: l10n.matches,
          value: '${controller.matchedPairs}/${controller.totalPairs}',
        ),
        _Stat(label: l10n.mistakes, value: '${controller.mistakes}'),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: theme.textTheme.headlineSmall),
        Text(label, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({required this.card, required this.onTap});

  final MemoryCard card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final revealed = card.isFaceUp || card.isMatched;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: card.isMatched
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        child: Center(
          child: revealed
              ? Text(card.value, style: const TextStyle(fontSize: 40))
              : Icon(
                  Icons.help_outline,
                  size: 36,
                  color: theme.colorScheme.primary,
                ),
        ),
      ),
    );
  }
}

class _CompletionPanel extends StatelessWidget {
  const _CompletionPanel({required this.controller, required this.l10n});

  final MemoryMatchController controller;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.wellDone, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(l10n.gameSummary, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('${l10n.moves}: ${controller.moves}'),
            Text('${l10n.mistakes}: ${controller.mistakes}'),
            Text('${l10n.time}: ${controller.elapsedSeconds}s'),
            const SizedBox(height: 8),
            Text(
              l10n.performanceOnlyNote,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: controller.restart,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.playAgain),
            ),
          ],
        ),
      ),
    );
  }
}
