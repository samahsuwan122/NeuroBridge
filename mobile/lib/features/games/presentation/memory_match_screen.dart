import 'package:flutter/material.dart';

import '../../../core/app_scope.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/emerald_panel.dart';
import '../../../core/widgets/language_button.dart';
import '../application/game_result_controller.dart';
import '../application/memory_match_controller.dart';
import '../data/game_definition.dart';
import '../data/memory_card.dart';

/// Playable Memory Match exercise (mobile). On completion the result is
/// auto-submitted once as game performance only (no medical interpretation).
class MemoryMatchScreen extends StatefulWidget {
  const MemoryMatchScreen({super.key, this.game});

  final GameDefinition? game;

  @override
  State<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _MemoryMatchScreenState extends State<MemoryMatchScreen> {
  final MemoryMatchController _controller = MemoryMatchController();
  GameResultController? _submitter;
  bool _submitAttempted = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onGameChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _submitter = AppScope.of(context).gameResults;
  }

  @override
  void dispose() {
    _controller.removeListener(_onGameChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onGameChanged() {
    // Auto-submit once when the game is completed (only if we know the game id).
    if (_controller.completed &&
        !_submitAttempted &&
        widget.game != null &&
        _submitter != null) {
      _submitAttempted = true;
      _submitResult();
    }
  }

  void _submitResult() {
    final game = widget.game;
    final submitter = _submitter;
    if (game == null || submitter == null) return;
    submitter.submit(
      gameId: game.id,
      score: _controller.matchedPairs,
      maxScore: _controller.totalPairs,
      durationSeconds: _controller.elapsedSeconds,
      completed: true,
      metrics: {
        'moves': _controller.moves,
        'mistakes': _controller.mistakes,
        'matched_pairs': _controller.matchedPairs,
        'total_pairs': _controller.totalPairs,
      },
    );
  }

  void _playAgain() {
    _submitAttempted = false;
    _submitter?.reset();
    _controller.restart();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final submitter = AppScope.of(context).gameResults;

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
              animation: Listenable.merge([_controller, submitter]),
              builder: (context, _) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _StatsRow(controller: _controller, l10n: l10n),
                      const SizedBox(height: 12),
                      if (_controller.completed) ...[
                        _CompletionPanel(
                          controller: _controller,
                          l10n: l10n,
                          submitStatus:
                              widget.game != null ? submitter.status : null,
                          onRetrySave: _submitResult,
                          onPlayAgain: _playAgain,
                        ),
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
    final scheme = Theme.of(context).colorScheme;
    final revealed = card.isFaceUp || card.isMatched;
    final Color background = card.isMatched
        ? scheme.primaryContainer
        : (card.isFaceUp ? AppColors.warmWhite : scheme.surfaceContainerHighest);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: card.isMatched ? AppColors.softGold : AppColors.warmStone,
            width: card.isMatched ? 2 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: revealed
              ? Text(card.value, style: const TextStyle(fontSize: 40))
              : Icon(Icons.help_outline, size: 34, color: scheme.primary),
        ),
      ),
    );
  }
}

class _CompletionPanel extends StatelessWidget {
  const _CompletionPanel({
    required this.controller,
    required this.l10n,
    required this.submitStatus,
    required this.onRetrySave,
    required this.onPlayAgain,
  });

  final MemoryMatchController controller;
  final AppLocalizations l10n;
  final SubmitStatus? submitStatus;
  final VoidCallback onRetrySave;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.heroStart, AppColors.heroEnd],
              ),
            ),
            child: Row(
              children: [
                const IconChip(
                  icon: Icons.emoji_events_rounded,
                  size: 44,
                  background: Color(0x22FFFFFF),
                  foreground: AppColors.softGold,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.wellDone,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.onHero,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.gameSummary, style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                Text('${l10n.moves}: ${controller.moves}'),
                Text('${l10n.mistakes}: ${controller.mistakes}'),
                Text('${l10n.time}: ${controller.elapsedSeconds}s'),
                const SizedBox(height: 8),
                Text(l10n.performanceOnlyNote,
                    style: theme.textTheme.bodySmall),
                if (submitStatus != null) ...[
                  const SizedBox(height: 12),
                  _SubmissionRow(
                    status: submitStatus!,
                    l10n: l10n,
                    onRetry: onRetrySave,
                  ),
                ],
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: onPlayAgain,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.playAgain),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmissionRow extends StatelessWidget {
  const _SubmissionRow({
    required this.status,
    required this.l10n,
    required this.onRetry,
  });

  final SubmitStatus status;
  final AppLocalizations l10n;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    switch (status) {
      case SubmitStatus.idle:
      case SubmitStatus.submitting:
        return Row(
          children: [
            const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(l10n.savingResult),
          ],
        );
      case SubmitStatus.saved:
        return Row(
          children: [
            Icon(Icons.check_circle, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(l10n.resultSaved),
          ],
        );
      case SubmitStatus.error:
        return Row(
          children: [
            Expanded(child: Text(l10n.resultSaveFailed)),
            TextButton(onPressed: onRetry, child: Text(l10n.retrySave)),
          ],
        );
    }
  }
}
