import 'package:flutter/material.dart';

import '../../../core/app_scope.dart';
import '../../../core/localization/app_localizations.dart';
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
            child: Text(l10n.noProgressYet, textAlign: TextAlign.center),
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
            Text(result.gameTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 6),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                Text('${l10n.score}: $scoreText'),
                if (result.durationSeconds != null)
                  Text('${l10n.duration}: ${result.durationSeconds}s'),
                Text(result.completed ? l10n.completed : l10n.notCompleted),
              ],
            ),
            if (result.moves != null || result.mistakes != null) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 16,
                children: [
                  if (result.moves != null)
                    Text('${l10n.moves}: ${result.moves}'),
                  if (result.mistakes != null)
                    Text('${l10n.mistakes}: ${result.mistakes}'),
                ],
              ),
            ],
            if (result.shortDate.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('${l10n.date}: ${result.shortDate}',
                  style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
