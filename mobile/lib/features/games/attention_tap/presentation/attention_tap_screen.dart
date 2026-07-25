import 'package:flutter/material.dart';

import '../../../../core/app_scope.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/emerald_panel.dart';
import '../../../../core/widgets/language_button.dart';
import '../../application/game_result_controller.dart';
import '../../data/game_definition.dart';
import '../application/attention_tap_controller.dart';

/// Playable Attention Tap exercise. Each round shows a grid of icons; tap the
/// one matching the target. After several rounds it shows correct/mistakes/
/// accuracy and submits the result as game performance only — no medical
/// assessment or interpretation.
class AttentionTapScreen extends StatefulWidget {
  const AttentionTapScreen({super.key, this.game, this.controller});

  final GameDefinition? game;

  /// Injectable for tests; production builds a default controller.
  final AttentionTapController? controller;

  @override
  State<AttentionTapScreen> createState() => _AttentionTapScreenState();
}

class _AttentionTapScreenState extends State<AttentionTapScreen> {
  late final AttentionTapController _controller;
  late final bool _ownsController;
  GameResultController? _submitter;
  bool _submitAttempted = false;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? AttentionTapController();
    _controller.addListener(_onChanged);
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
    if (_controller.isFinished &&
        !_submitAttempted &&
        widget.game != null &&
        _submitter != null) {
      _submitAttempted = true;
      _submitter!.submit(
        gameId: widget.game!.id,
        score: _controller.correctCount,
        maxScore: _controller.totalRounds,
        durationSeconds: _controller.elapsedSeconds,
        completed: true,
        metrics: _controller.resultMetrics,
      );
    }
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
        title: Text(widget.game?.name ?? l10n.attentionTap),
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
      case AttentionStatus.idle:
        return _Instructions(
          l10n: l10n,
          instructions: widget.game?.instructions,
          onStart: _controller.start,
        );
      case AttentionStatus.playing:
        return _Play(controller: _controller, l10n: l10n);
      case AttentionStatus.finished:
        return _Summary(
          controller: _controller,
          l10n: l10n,
          submitStatus: widget.game != null ? submitter.status : null,
          onPlayAgain: _playAgain,
        );
    }
  }
}

class _Instructions extends StatelessWidget {
  const _Instructions({
    required this.l10n,
    required this.instructions,
    required this.onStart,
  });

  final AppLocalizations l10n;
  final String? instructions;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.attentionTapSubtitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(l10n.attentionTapNote, style: theme.textTheme.bodySmall),
          if ((instructions ?? '').isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(instructions!, style: theme.textTheme.bodyLarge),
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow),
            label: Text(l10n.startAttentionTap),
          ),
        ],
      ),
    );
  }
}

class _Play extends StatelessWidget {
  const _Play({required this.controller, required this.l10n});

  final AttentionTapController controller;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final target = controller.target;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.tapTheTarget,
                    style: theme.textTheme.titleLarge),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${controller.completedRounds} / ${controller.totalRounds}',
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (target != null)
            Row(
              children: [
                Text('${l10n.target}: ', style: theme.textTheme.titleMedium),
                IconChip(icon: target, size: 44),
              ],
            ),
          const SizedBox(height: 8),
          SizedBox(height: 24, child: _Feedback(controller: controller, l10n: l10n)),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                for (var i = 0; i < controller.cells.length; i++)
                  _Cell(
                    key: ValueKey('attention_cell_$i'),
                    icon: controller.cells[i],
                    onTap: () => controller.tapCell(i),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({required this.controller, required this.l10n});

  final AttentionTapController controller;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final correct = controller.lastTapCorrect;
    if (correct == null) return const SizedBox.shrink();
    return Row(
      children: [
        Icon(correct ? Icons.check_circle : Icons.info_outline,
            size: 18,
            color: correct ? theme.colorScheme.primary : theme.colorScheme.error),
        const SizedBox(width: 6),
        Text(
          correct ? l10n.correctTap : l10n.missedTarget,
          style: TextStyle(
              color:
                  correct ? theme.colorScheme.primary : theme.colorScheme.error),
        ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: AppColors.warmWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.warmStone),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Center(
          child: Icon(icon, size: 44, color: theme.colorScheme.primary),
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.controller,
    required this.l10n,
    required this.submitStatus,
    required this.onPlayAgain,
  });

  final AttentionTapController controller;
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
                  icon: Icons.center_focus_strong_rounded,
                  size: 52,
                  background: Color(0x22FFFFFF),
                  foreground: AppColors.softGold,
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.attentionComplete,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(color: AppColors.onHero),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _Stat(
                        label: l10n.correctCount,
                        value: '${controller.correctCount}'),
                    _Stat(
                        label: l10n.mistakes,
                        value: '${controller.mistakeCount}'),
                    _Stat(
                        label: l10n.accuracy,
                        value: '${controller.accuracyPercent}%'),
                    _Stat(
                        label: l10n.roundsCompleted,
                        value: '${controller.completedRounds}'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.attentionTapNote,
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

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value,
            style: theme.textTheme.titleLarge?.copyWith(
                color: AppColors.onHero, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: AppColors.onHeroMuted)),
      ],
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
