import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/app_scope.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/emerald_panel.dart';
import '../../../../core/widgets/language_button.dart';
import '../../application/game_result_controller.dart';
import '../../data/game_definition.dart';
import '../application/reaction_time_controller.dart';

/// Playable Reaction Time exercise. Wait for the signal, then tap fast. After
/// several rounds it shows best/average times and submits the result as game
/// performance only — no medical assessment or interpretation.
class ReactionTimeScreen extends StatefulWidget {
  const ReactionTimeScreen({super.key, this.game, this.controller});

  final GameDefinition? game;

  /// Injectable for tests; production builds a default controller.
  final ReactionTimeController? controller;

  @override
  State<ReactionTimeScreen> createState() => _ReactionTimeScreenState();
}

class _ReactionTimeScreenState extends State<ReactionTimeScreen> {
  late final ReactionTimeController _controller;
  late final bool _ownsController;
  Timer? _timer;
  GameResultController? _submitter;
  bool _submitAttempted = false;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? ReactionTimeController();
    _controller.addListener(_onChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _submitter = AppScope.of(context).gameResults;
  }

  @override
  void dispose() {
    _timer?.cancel();
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
        score: _controller.completedRounds,
        maxScore: _controller.totalRounds,
        durationSeconds: _controller.elapsedSeconds,
        completed: true,
        metrics: _controller.resultMetrics,
      );
    }
  }

  void _startRound() {
    _timer?.cancel();
    final delay = _controller.beginRound();
    _timer = Timer(delay, () {
      if (mounted) _controller.signalGo();
    });
  }

  void _onTapArea() {
    _timer?.cancel();
    _controller.tap();
  }

  void _playAgain() {
    _timer?.cancel();
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
        title: Text(widget.game?.name ?? l10n.reactionTime),
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
      case ReactionStatus.idle:
        return _Instructions(
          l10n: l10n,
          instructions: widget.game?.instructions,
          onStart: _startRound,
        );
      case ReactionStatus.waiting:
        return _TapArea(
          l10n: l10n,
          controller: _controller,
          label: l10n.waitForSignal,
          background: Theme.of(context).colorScheme.surfaceContainerHighest,
          foreground: Theme.of(context).colorScheme.onSurfaceVariant,
          onTap: _onTapArea,
        );
      case ReactionStatus.ready:
        return _TapArea(
          l10n: l10n,
          controller: _controller,
          label: l10n.tapNow,
          background: AppColors.deepEmerald,
          foreground: AppColors.onHero,
          onTap: _onTapArea,
        );
      case ReactionStatus.tooSoon:
        return _Message(
          l10n: l10n,
          controller: _controller,
          message: l10n.tooSoon,
          isError: true,
          actionLabel: l10n.tryAgain,
          onAction: _startRound,
        );
      case ReactionStatus.roundResult:
        return _Message(
          l10n: l10n,
          controller: _controller,
          message: '${l10n.reactionTimeMs}: ${_controller.lastReactionMs} ms',
          isError: false,
          actionLabel: l10n.startRound,
          onAction: _startRound,
        );
      case ReactionStatus.finished:
        return _Summary(
          l10n: l10n,
          controller: _controller,
          submitStatus: widget.game != null ? submitter.status : null,
          onPlayAgain: _playAgain,
        );
    }
  }
}

class _RoundPill extends StatelessWidget {
  const _RoundPill({required this.controller});

  final ReactionTimeController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
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
    );
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
          Text(l10n.reactionTimeSubtitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(l10n.reactionTimeNote, style: theme.textTheme.bodySmall),
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
            label: Text(l10n.startRound),
          ),
        ],
      ),
    );
  }
}

class _TapArea extends StatelessWidget {
  const _TapArea({
    required this.l10n,
    required this.controller,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final ReactionTimeController controller;
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: _RoundPill(controller: controller),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GestureDetector(
              key: const Key('reaction_tap_area'),
              onTap: onTap,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: foreground, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.l10n,
    required this.controller,
    required this.message,
    required this.isError,
    required this.actionLabel,
    required this.onAction,
  });

  final AppLocalizations l10n;
  final ReactionTimeController controller;
  final String message;
  final bool isError;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _RoundPill(controller: controller),
          const SizedBox(height: 20),
          Icon(
            isError ? Icons.timer_off_outlined : Icons.timer_outlined,
            size: 44,
            color: isError
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
                color: isError ? theme.colorScheme.error : null),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.play_arrow),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.l10n,
    required this.controller,
    required this.submitStatus,
    required this.onPlayAgain,
  });

  final AppLocalizations l10n;
  final ReactionTimeController controller;
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
                  icon: Icons.bolt_rounded,
                  size: 52,
                  background: Color(0x22FFFFFF),
                  foreground: AppColors.softGold,
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.reactionComplete,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(color: AppColors.onHero),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _Stat(
                        label: l10n.bestReaction,
                        value: '${controller.bestReactionMs ?? 0} ms'),
                    _Stat(
                        label: l10n.averageReaction,
                        value: '${controller.averageReactionMs ?? 0} ms'),
                    _Stat(
                        label: l10n.roundsCompleted,
                        value: '${controller.completedRounds}'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.reactionTimeNote,
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
