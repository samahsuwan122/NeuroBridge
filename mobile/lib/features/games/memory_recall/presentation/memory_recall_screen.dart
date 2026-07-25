import 'package:flutter/material.dart';

import '../../../../core/app_scope.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/emerald_panel.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/language_button.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../memories/data/memories_api.dart';
import '../../../memories/presentation/memory_image_view.dart';
import '../../application/game_result_controller.dart';
import '../../data/game_definition.dart';
import '../application/memory_recall_controller.dart';
import '../data/memory_recall_question.dart';

/// Personalized Memory Recall exercise built from the patient's Memory Album.
///
/// Supportive family-recall activity only — no diagnosis, scoring
/// interpretation, or AI. On completion, results are submitted as game
/// performance only.
class MemoryRecallScreen extends StatefulWidget {
  const MemoryRecallScreen({super.key, this.game, this.controller});

  final GameDefinition? game;

  /// Injectable for tests; production builds a default controller.
  final MemoryRecallController? controller;

  @override
  State<MemoryRecallScreen> createState() => _MemoryRecallScreenState();
}

class _MemoryRecallScreenState extends State<MemoryRecallScreen> {
  late final MemoryRecallController _controller;
  late final bool _ownsController;
  GameResultController? _submitter;
  bool _submitAttempted = false;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ??
        MemoryRecallController(MemoriesApi(ApiClient()), SecureStorageService());
    _controller.addListener(_onChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.load();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _submitter = AppScope.of(context).gameResults;
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    // Submit once when finished (only if we know the game id).
    if (_controller.isFinished &&
        !_submitAttempted &&
        widget.game != null &&
        _submitter != null) {
      _submitAttempted = true;
      _submitter!.submit(
        gameId: widget.game!.id,
        score: _controller.score,
        maxScore: _controller.total,
        durationSeconds: _controller.elapsedSeconds,
        completed: true,
        metrics: _controller.resultMetrics,
      );
    }
  }

  void _playAgain() {
    _submitAttempted = false;
    _submitter?.reset();
    _controller.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final submitter = AppScope.of(context).gameResults;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game?.name ?? l10n.memoryRecall),
        actions: const [LanguageButton()],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: AnimatedBuilder(
              animation: Listenable.merge([_controller, submitter]),
              builder: (context, _) => _body(context, l10n, submitter),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    AppLocalizations l10n,
    GameResultController submitter,
  ) {
    switch (_controller.status) {
      case RecallStatus.loading:
        return Center(child: LoadingState(message: l10n.loadingGames));
      case RecallStatus.error:
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ErrorState(
            message: l10n.memoryRecallLoadFailed,
            retryLabel: l10n.retry,
            onRetry: _controller.load,
          ),
        );
      case RecallStatus.insufficient:
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo_library_outlined,
                  size: 44, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(height: 12),
              Text(l10n.notEnoughMemories,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text(l10n.addMoreMemoriesToStart, textAlign: TextAlign.center),
            ],
          ),
        );
      case RecallStatus.ready:
        return _controller.isFinished
            ? _Summary(
                controller: _controller,
                l10n: l10n,
                submitStatus: widget.game != null ? submitter.status : null,
                onPlayAgain: _playAgain,
              )
            : _Play(controller: _controller, l10n: l10n);
    }
  }
}

class _Play extends StatelessWidget {
  const _Play({required this.controller, required this.l10n});

  final MemoryRecallController controller;
  final AppLocalizations l10n;

  String _prompt(RecallQuestionType type) {
    switch (type) {
      case RecallQuestionType.person:
        return l10n.whoIsThisPerson;
      case RecallQuestionType.place:
        return l10n.whereWasThisMemory;
      case RecallQuestionType.category:
        return l10n.whatCategoryIsThisMemory;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final q = controller.currentQuestion;
    if (q == null) return const SizedBox.shrink();
    final imageUrl = q.memory.resolvedImageUrl(AppConfig.baseUrl);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.memoryRecallNote,
                    style: theme.textTheme.bodySmall),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${controller.currentIndex + 1} / ${controller.total}',
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (q.memory.hasImage && imageUrl != null)
            MemoryImageView(
              imageUrl: imageUrl,
              width: double.infinity,
              height: 200,
              borderRadius: 20,
              semanticLabel: l10n.memoryImage,
              unavailableLabel: l10n.imageUnavailable,
            )
          else
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.photo_outlined,
                  size: 40, color: theme.colorScheme.onSurfaceVariant),
            ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(_prompt(q.type), style: theme.textTheme.titleLarge),
                  const SizedBox(height: 14),
                  for (var i = 0; i < q.options.length; i++)
                    _OptionTile(
                      label: q.options[i],
                      index: i,
                      controller: controller,
                    ),
                  _Feedback(controller: controller, l10n: l10n),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: controller.answeredCorrectly ? controller.next : null,
            icon: Icon(controller.isLastQuestion
                ? Icons.flag_outlined
                : Icons.arrow_forward),
            label: Text(controller.isLastQuestion
                ? l10n.finishExercise
                : l10n.nextQuestion),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.index,
    required this.controller,
  });

  final String label;
  final int index;
  final MemoryRecallController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final q = controller.currentQuestion!;
    final isCorrectOption = q.isCorrect(label);
    final isSelected = controller.selectedOption == index;
    final answered = controller.answeredCorrectly;

    Color? bg;
    if (answered && isCorrectOption) {
      bg = theme.colorScheme.primaryContainer;
    } else if (isSelected && !isCorrectOption) {
      bg = theme.colorScheme.errorContainer;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: bg ?? theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppColors.warmStone),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: answered ? null : () => controller.answer(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text(label, style: theme.textTheme.titleMedium),
          ),
        ),
      ),
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({required this.controller, required this.l10n});

  final MemoryRecallController controller;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (controller.answeredCorrectly) {
      return Row(
        children: [
          Icon(Icons.check_circle, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(l10n.correct,
              style: TextStyle(color: theme.colorScheme.primary)),
        ],
      );
    }
    if (controller.selectedOption != null) {
      return Text(l10n.tryAgain,
          style: TextStyle(color: theme.colorScheme.error));
    }
    return const SizedBox.shrink();
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.controller,
    required this.l10n,
    required this.submitStatus,
    required this.onPlayAgain,
  });

  final MemoryRecallController controller;
  final AppLocalizations l10n;
  final SubmitStatus? submitStatus;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EmeraldPanel(
            child: Column(
              children: [
                const IconChip(
                  icon: Icons.emoji_events_rounded,
                  size: 52,
                  background: Color(0x22FFFFFF),
                  foreground: AppColors.softGold,
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.recallComplete,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(color: AppColors.onHero),
                ),
                const SizedBox(height: 8),
                Text(
                  '${l10n.recallScore}: ${controller.score}/${controller.total}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.onHero,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.memoryRecallNote,
              style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
          if (submitStatus != null) ...[
            const SizedBox(height: 16),
            _SubmitRow(status: submitStatus!, l10n: l10n),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onPlayAgain,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.playAgain),
          ),
        ],
      ),
    );
  }
}

class _SubmitRow extends StatelessWidget {
  const _SubmitRow({required this.status, required this.l10n});

  final SubmitStatus status;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    switch (status) {
      case SubmitStatus.idle:
      case SubmitStatus.submitting:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 8),
            Text(l10n.savingResult),
          ],
        );
      case SubmitStatus.saved:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(l10n.resultSaved),
          ],
        );
      case SubmitStatus.error:
        return Text(l10n.resultSaveFailed,
            style: TextStyle(color: theme.colorScheme.error),
            textAlign: TextAlign.center);
    }
  }
}
