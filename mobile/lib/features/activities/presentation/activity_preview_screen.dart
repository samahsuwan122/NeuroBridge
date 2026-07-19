import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_scope.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../data/assigned_activity.dart';

/// Safe, elderly-friendly preview of a single assigned activity: big text,
/// simple instructions, a large "Start activity" button (when the activity maps
/// to an in-app game) and a large "Mark as completed" button.
///
/// Cognitive exercise only — no medical content of any kind.
class ActivityPreviewScreen extends StatefulWidget {
  const ActivityPreviewScreen({super.key, required this.activity});

  final AssignedActivity? activity;

  @override
  State<ActivityPreviewScreen> createState() => _ActivityPreviewScreenState();
}

class _ActivityPreviewScreenState extends State<ActivityPreviewScreen> {
  bool _busy = false;

  String _difficultyLabel(AppLocalizations l10n, String difficulty) {
    switch (difficulty) {
      case 'easy':
        return l10n.difficultyEasy;
      case 'medium':
        return l10n.difficultyMedium;
      case 'hard':
        return l10n.difficultyHard;
      default:
        return difficulty;
    }
  }

  Future<void> _markCompleted(AssignedActivity activity) async {
    final scope = AppScope.of(context);
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    final ok = await scope.activities?.setStatus(activity) ?? false;
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.greatJob)),
      );
      if (context.canPop()) context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.networkError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final activity = widget.activity;

    return Scaffold(
      appBar: AppBar(title: Text(activity?.title ?? l10n.activities)),
      body: activity == null
          ? Center(child: Text(l10n.noAssignedActivities))
          : SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          activity.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurfaceDeep,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _InfoChip(
                              icon: Icons.tune,
                              label: _difficultyLabel(l10n, activity.difficulty),
                            ),
                            _InfoChip(
                              icon: Icons.schedule,
                              label:
                                  '${activity.durationMinutes} ${l10n.minutesLabel}',
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        if ((activity.instructions ?? '').trim().isNotEmpty) ...[
                          Text(
                            l10n.howToDoIt,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.goldTint.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.softGold),
                            ),
                            child: Text(
                              activity.instructions!.trim(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                height: 1.5,
                                color: AppColors.onSurfaceDeep,
                              ),
                            ),
                          ),
                          const SizedBox(height: 26),
                        ],
                        if (activity.isCompleted)
                          _CompletedBanner(label: l10n.activityDone)
                        else ...[
                          if (activity.isPlayable)
                            SizedBox(
                              height: 60,
                              child: FilledButton.icon(
                                onPressed: _busy
                                    ? null
                                    : () => context.push(
                                          activity.gameRoute!,
                                        ),
                                icon: const Icon(Icons.play_arrow, size: 28),
                                label: Text(
                                  l10n.startActivity,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 60,
                            child: OutlinedButton.icon(
                              onPressed:
                                  _busy ? null : () => _markCompleted(activity),
                              icon: const Icon(Icons.check_circle_outline,
                                  size: 28),
                              label: Text(
                                l10n.markCompleted,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.sageTint.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.warmStone),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.onSurfaceMuted),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceDeep,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedBanner extends StatelessWidget {
  const _CompletedBanner({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.emeraldTint.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.deepEmerald, size: 28),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.deepEmerald,
            ),
          ),
        ],
      ),
    );
  }
}
