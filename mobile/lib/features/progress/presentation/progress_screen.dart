import 'package:flutter/material.dart';

import '../../../core/app_scope.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/emerald_panel.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/language_button.dart';
import '../../../core/widgets/loading_state.dart';
import '../application/progress_controller.dart';
import '../data/game_result_summary.dart';

/// Patient progress: a list of saved cognitive-exercise results.
///
/// Game/exercise performance only — no diagnosis or medical interpretation.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppScope.of(context).progress.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = AppScope.of(context).progress;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.progress),
        actions: const [LanguageButton()],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: AnimatedBuilder(
              animation: progress,
              builder: (context, _) => _body(context, progress, l10n),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    ProgressController progress,
    AppLocalizations l10n,
  ) {
    switch (progress.status) {
      case ProgressStatus.initial:
      case ProgressStatus.loading:
        return Center(child: LoadingState(message: l10n.loadingProgress));
      case ProgressStatus.error:
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ErrorState(
            message: l10n.progressLoadFailed,
            retryLabel: l10n.retry,
            onRetry: progress.load,
          ),
        );
      case ProgressStatus.empty:
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.insights_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(height: 12),
                Text(l10n.noProgressYet,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        );
      case ProgressStatus.loaded:
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.progressSubtitle,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(l10n.performanceOnlyProgressNote,
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            for (final result in progress.results)
              _ResultCard(result: result, l10n: l10n),
          ],
        );
    }
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result, required this.l10n});

  final GameResultSummary result;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scoreText = (result.score != null && result.maxScore != null)
        ? '${result.score}/${result.maxScore}'
        : (result.score?.toString() ?? '—');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const IconChip(icon: Icons.emoji_events_outlined, size: 46),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(result.gameTitle,
                      style: theme.textTheme.titleLarge),
                ),
                _CompletionChip(completed: result.completed, l10n: l10n),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatPill(label: l10n.score, value: scoreText),
                if (result.durationSeconds != null)
                  _StatPill(
                      label: l10n.duration,
                      value: '${result.durationSeconds}s'),
                if (result.moves != null)
                  _StatPill(label: l10n.moves, value: '${result.moves}'),
                if (result.mistakes != null)
                  _StatPill(label: l10n.mistakes, value: '${result.mistakes}'),
              ],
            ),
            if (result.shortDate.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('${l10n.date}: ${result.shortDate}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Text(value, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _CompletionChip extends StatelessWidget {
  const _CompletionChip({required this.completed, required this.l10n});

  final bool completed;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color bg = completed
        ? theme.colorScheme.tertiaryContainer
        : theme.colorScheme.surfaceContainerHighest;
    final Color fg = completed
        ? theme.colorScheme.onTertiaryContainer
        : theme.colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: completed ? Border.all(color: AppColors.softGold) : null,
      ),
      child: Text(
        completed ? l10n.completed : l10n.notCompleted,
        style: theme.textTheme.labelMedium
            ?.copyWith(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}
