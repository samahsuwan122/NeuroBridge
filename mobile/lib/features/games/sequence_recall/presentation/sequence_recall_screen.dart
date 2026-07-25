import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/app_scope.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/emerald_panel.dart';
import '../../../../core/widgets/language_button.dart';
import '../../application/game_result_controller.dart';
import '../../data/game_definition.dart';
import '../application/sequence_recall_controller.dart';

/// Palette of tile colors (distinct, on-brand). Index == tile id.
const List<Color> _tileColors = [
  AppColors.deepEmerald,
  AppColors.softGold,
  AppColors.mutedSage,
  Color(0xFF7C6F9B), // muted plum
];

/// Playable Sequence Recall exercise. Watch a sequence, then repeat it. After
/// several rounds it shows correct/mistakes/longest/accuracy and submits the
/// result as game performance only — no medical assessment or interpretation.
class SequenceRecallScreen extends StatefulWidget {
  const SequenceRecallScreen({super.key, this.game, this.controller});

  final GameDefinition? game;

  /// Injectable for tests; production builds a default controller.
  final SequenceRecallController? controller;

  @override
  State<SequenceRecallScreen> createState() => _SequenceRecallScreenState();
}

class _SequenceRecallScreenState extends State<SequenceRecallScreen> {
  late final SequenceRecallController _controller;
  late final bool _ownsController;
  Timer? _watchTimer;
  int _watchStep = -1; // tile currently highlighted during watch (-1 = none)
  GameResultController? _submitter;
  bool _submitAttempted = false;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? SequenceRecallController();
    _controller.addListener(_onChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _submitter = AppScope.of(context).gameResults;
  }

  @override
  void dispose() {
    _watchTimer?.cancel();
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

  void _onStart() {
    _controller.start();
    _runWatch();
  }

  void _onContinue() {
    _controller.continueGame();
    if (_controller.status == SequenceStatus.watch) _runWatch();
  }

  void _playAgain() {
    _watchTimer?.cancel();
    _submitAttempted = false;
    _submitter?.reset();
    _controller.restart();
  }

  /// Reveal the sequence tile-by-tile, then switch to input mode.
  void _runWatch() {
    _watchTimer?.cancel();
    var i = 0;
    setState(() => _watchStep = -1);
    _watchTimer = Timer.periodic(const Duration(milliseconds: 750), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (i >= _controller.sequence.length) {
        t.cancel();
        setState(() => _watchStep = -1);
        _controller.beginInput();
        return;
      }
      setState(() => _watchStep = _controller.sequence[i]);
      i++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final submitter = AppScope.of(context).gameResults;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game?.name ?? l10n.sequenceRecall),
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
      case SequenceStatus.idle:
        return _Instructions(
          l10n: l10n,
          instructions: widget.game?.instructions,
          onStart: _onStart,
        );
      case SequenceStatus.watch:
      case SequenceStatus.input:
      case SequenceStatus.roundResult:
        return _Play(
          controller: _controller,
          l10n: l10n,
          watchStep: _watchStep,
          onTile: (i) => _controller.tapTile(i),
          onContinue: _onContinue,
        );
      case SequenceStatus.finished:
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
          Text(l10n.sequenceRecallSubtitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(l10n.sequenceRecallNote, style: theme.textTheme.bodySmall),
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
            label: Text(l10n.startSequenceRecall),
          ),
        ],
      ),
    );
  }
}

class _Play extends StatelessWidget {
  const _Play({
    required this.controller,
    required this.l10n,
    required this.watchStep,
    required this.onTile,
    required this.onContinue,
  });

  final SequenceRecallController controller;
  final AppLocalizations l10n;
  final int watchStep;
  final ValueChanged<int> onTile;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final watching = controller.status == SequenceStatus.watch;
    final input = controller.status == SequenceStatus.input;
    final result = controller.status == SequenceStatus.roundResult;

    String phaseLabel;
    if (watching) {
      phaseLabel = l10n.watchSequence;
    } else if (input) {
      phaseLabel = l10n.repeatSequence;
    } else {
      phaseLabel = controller.lastRoundCorrect == true
          ? l10n.correctSequence
          : l10n.wrongSequence;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(phaseLabel, style: theme.textTheme.titleLarge),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${controller.completedRounds + 1} / ${controller.totalRounds}',
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (input)
            Text('${controller.inputLength} / ${controller.sequence.length}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                for (var i = 0; i < controller.tileCount; i++)
                  _Tile(
                    key: ValueKey('seq_tile_$i'),
                    color: _tileColors[i % _tileColors.length],
                    highlighted: watching && watchStep == i,
                    enabled: input,
                    onTap: () => onTile(i),
                  ),
              ],
            ),
          ),
          if (result) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onContinue,
              icon: const Icon(Icons.arrow_forward),
              label: Text(l10n.startRound),
            ),
          ],
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    super.key,
    required this.color,
    required this.highlighted,
    required this.enabled,
    required this.onTap,
  });

  final Color color;
  final bool highlighted;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: highlighted ? 1.0 : (enabled ? 0.9 : 0.45),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: enabled ? onTap : null,
          child: const SizedBox.expand(),
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

  final SequenceRecallController controller;
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
                  icon: Icons.reorder_rounded,
                  size: 52,
                  background: Color(0x22FFFFFF),
                  foreground: AppColors.softGold,
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.sequenceComplete,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(color: AppColors.onHero),
                ),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 24,
                  runSpacing: 12,
                  children: [
                    _Stat(
                        label: l10n.correctCount,
                        value: '${controller.correctCount}'),
                    _Stat(
                        label: l10n.mistakes,
                        value: '${controller.mistakeCount}'),
                    _Stat(
                        label: l10n.longestSequence,
                        value: '${controller.longestSequence}'),
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
          Text(l10n.sequenceRecallNote,
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
      mainAxisSize: MainAxisSize.min,
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
