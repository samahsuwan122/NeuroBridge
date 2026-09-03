import 'package:flutter/material.dart';

import '../../core/services/today_plan_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/patient_page.dart';
import 'exercise_details_screen.dart';
import 'exercises_screen.dart';

class TodayPlanScreen extends StatefulWidget {
  const TodayPlanScreen({super.key});

  @override
  State<TodayPlanScreen> createState() => _TodayPlanScreenState();
}

class _TodayPlanScreenState extends State<TodayPlanScreen> {
  TodayPlanData? _plan;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final plan = await TodayPlanService.load();
      if (!mounted) return;
      setState(() {
        _plan = plan;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _openItem(TodayPlanItem item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseDetailsScreen(exercise: item.exercise),
      ),
    );
    if (mounted) await _load();
  }

  Future<void> _continuePlan() async {
    final plan = _plan;
    if (plan == null || plan.items.isEmpty) return;

    TodayPlanItem? next;
    for (final item in plan.items) {
      if (!item.completed) {
        next = item;
        break;
      }
    }

    if (next != null) {
      await _openItem(next);
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ExercisesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plan = _plan;
    final progress = plan?.progress ?? 0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PatientPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_loading) const LinearProgressIndicator(minHeight: 2),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_forward_ios_rounded),
                  ),
                  const Expanded(
                    child: Text(
                      'خطة اليوم',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _loading ? null : _load,
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'تحديث الخطة',
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 20),
                NeuroCard(
                  child: Column(
                    children: [
                      const Icon(Icons.cloud_off_rounded, size: 40),
                      const SizedBox(height: 10),
                      Text(_error!, textAlign: TextAlign.center),
                      TextButton(
                        onPressed: _load,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              ] else if (!_loading && plan != null) ...[
                const SizedBox(height: 20),
                NeuroCard(
                  color: const Color(0xFFF1E7D8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'إنجاز اليوم',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                          Text(
                            '$progress%',
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: progress / 100,
                          minHeight: 9,
                          backgroundColor: const Color(0xFFE1D1BC),
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text('${plan.completed} من ${plan.total} مكتملة'),
                          const Spacer(),
                          Text('${plan.remainingMinutes} دقيقة متبقية'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const PatientSectionTitle(title: 'تمارين الجلسة'),
                const SizedBox(height: 12),
                if (plan.items.isEmpty)
                  const NeuroCard(
                    child: Center(
                      child: Text('لا توجد تمارين منشورة في الخطة حاليًا.'),
                    ),
                  )
                else
                  ...plan.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: NeuroCard(
                        onTap: () => _openItem(item),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: item.exercise.color.withValues(alpha: .13),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(
                                item.exercise.icon,
                                color: item.exercise.color,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.exercise.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.completed
                                        ? 'مكتمل • أفضل نتيجة ${item.bestScore}%'
                                        : '${item.exercise.durationMinutes} دقائق • ${item.exercise.difficultyTitle}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              item.completed
                                  ? Icons.check_circle_rounded
                                  : Icons.play_circle_outline_rounded,
                              color: item.completed
                                  ? const Color(0xFF71947A)
                                  : AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: FilledButton.icon(
                    onPressed: plan.items.isEmpty ? null : _continuePlan,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: Icon(
                      progress == 100
                          ? Icons.grid_view_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    label: Text(
                      progress == 100
                          ? 'استكشاف تمارين أخرى'
                          : 'متابعة جلسة اليوم',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
