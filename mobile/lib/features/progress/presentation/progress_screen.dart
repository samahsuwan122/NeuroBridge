import 'package:flutter/material.dart';

import '../../../core/app_scope.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/emerald_panel.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/language_button.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/widgets/section_header.dart';
import '../application/progress_controller.dart';
import '../data/game_result_summary.dart';
import '../data/progress_analytics.dart';

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
        return _Dashboard(results: progress.results, l10n: l10n);
    }
  }
}

/// A premium, performance-only analytics dashboard: summary cards, a per-game
/// breakdown, and recent activity. No diagnosis or medical interpretation.
class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.results, required this.l10n});

  final List<GameResultSummary> results;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final a = ProgressAnalytics.from(results);
    final recent = results.take(8).toList();

    String pct(int? v) => v == null ? '—' : '$v%';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.performanceSummary, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(l10n.progressAnalyticsNote, style: theme.textTheme.bodySmall),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                  icon: Icons.fitness_center,
                  label: l10n.totalExercises,
                  value: '${a.totalExercises}'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                  icon: Icons.check_circle_outline,
                  label: l10n.completedExercises,
                  value: '${a.completedExercises}'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                  icon: Icons.emoji_events_outlined,
                  label: l10n.bestPerformance,
                  value: pct(a.bestPercent)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                  icon: Icons.show_chart,
                  label: l10n.averagePerformance,
                  value: pct(a.averagePercent)),
            ),
          ],
        ),
        if (a.latestTitle != null) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const IconChip(icon: Icons.history, size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.latestActivity,
                            style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 2),
                        Text(a.latestTitle!, style: theme.textTheme.titleMedium),
                        if ((a.latestDate ?? '').isNotEmpty)
                          Text(a.latestDate!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        SectionHeader(icon: Icons.bar_chart, title: l10n.gameBreakdown),
        const SizedBox(height: 10),
        for (final b in a.breakdown) _BreakdownCard(breakdown: b, l10n: l10n),
        const SizedBox(height: 20),
        SectionHeader(icon: Icons.access_time, title: l10n.recentActivity),
        const SizedBox(height: 10),
        for (final result in recent) _ResultCard(result: result, l10n: l10n),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconChip(icon: icon, size: 38),
            const SizedBox(height: 10),
            Text(value, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 2),
            Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({required this.breakdown, required this.l10n});

  final GameBreakdown breakdown;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final best = breakdown.bestPercent == null
        ? l10n.noResultsYet
        : '${l10n.bestPerformance}: ${breakdown.bestPercent}%';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const IconChip(icon: Icons.videogame_asset_rounded, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(breakdown.title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(best,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            _StatPill(label: l10n.completedExercises, value: '${breakdown.count}'),
          ],
        ),
      ),
    );
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
