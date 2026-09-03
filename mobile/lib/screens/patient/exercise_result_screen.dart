import 'package:flutter/material.dart';

import '../../core/services/exercise_progress_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/patient_page.dart';
import 'today_plan_screen.dart';

class ExerciseResultScreen extends StatefulWidget {
  final int correctAnswers;
  final int totalQuestions;
  final String duration;
  final String? extraText;

  const ExerciseResultScreen({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.duration,
    this.extraText,
  });

  @override
  State<ExerciseResultScreen> createState() => _ExerciseResultScreenState();
}

class _ExerciseResultScreenState extends State<ExerciseResultScreen> {
  bool _saving = true;
  bool _saved = false;

  double get percentage => widget.totalQuestions == 0
      ? 0
      : widget.correctAnswers / widget.totalQuestions;

  @override
  void initState() {
    super.initState();
    _save();
  }

  int _durationSeconds(String value) {
    final parts = value.split(':');
    if (parts.length == 2) {
      return (int.tryParse(parts[0]) ?? 0) * 60 +
          (int.tryParse(parts[1]) ?? 0);
    }
    return int.tryParse(value) ?? 0;
  }

  Future<void> _save() async {
    try {
      await ExerciseProgressService.saveResult(
        score: widget.correctAnswers,
        totalQuestions: widget.totalQuestions,
        durationSeconds: _durationSeconds(widget.duration),
      );
      if (mounted) setState(() => _saved = true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.toString().replaceFirst('Exception: ', '')),
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PatientPage(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE8EE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.celebration_rounded,
                    size: 62, color: AppColors.primary),
              ),
              const SizedBox(height: 23),
              const Text('أحسنت، أكملت التمرين! 🌷',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  )),
              const SizedBox(height: 9),
              Text(
                _saving
                    ? 'جارٍ حفظ نتيجتك...'
                    : _saved
                        ? 'تم حفظ النتيجة في تقدّمك ✓'
                        : 'اكتمل التمرين، لكن لم تُحفظ النتيجة.',
                style: TextStyle(
                  color: _saved ? const Color(0xFF71947A) : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 25),
              Row(children: [
                Expanded(child: _Stat(
                  icon: Icons.task_alt_rounded,
                  value: '${widget.correctAnswers} / ${widget.totalQuestions}',
                  label: 'إجابات صحيحة',
                )),
                const SizedBox(width: 11),
                Expanded(child: _Stat(
                  icon: Icons.insights_rounded,
                  value: '${(percentage * 100).round()}%',
                  label: 'نسبة الأداء',
                )),
                const SizedBox(width: 11),
                Expanded(child: _Stat(
                  icon: Icons.schedule_rounded,
                  value: widget.duration,
                  label: 'المدة',
                )),
              ]),
              if (widget.extraText != null) ...[
                const SizedBox(height: 12),
                NeuroCard(child: Center(child: Text(widget.extraText!,
                    style: const TextStyle(fontWeight: FontWeight.w800)))),
              ],
              const SizedBox(height: 18),
              NeuroCard(
                color: const Color(0xFFEAF4ED),
                child: Row(children: [
                  const Icon(Icons.trending_up_rounded, color: Color(0xFF71947A)),
                  const SizedBox(width: 11),
                  Expanded(child: Text(
                    percentage >= .7
                        ? 'تقدّم جميل، استمر بهذا الأداء.'
                        : 'محاولة جيدة، ويمكنك التحسن بالممارسة.',
                    style: const TextStyle(height: 1.6, color: Color(0xFF5F7464)),
                  )),
                ]),
              ),
              const SizedBox(height: 23),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('المحاولة مجددًا'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _saving ? null : () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const TodayPlanScreen()),
                      (route) => route.isFirst,
                    );
                  },
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('العودة لخطة اليوم',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _Stat({required this.icon, required this.value, required this.label});
  @override
  Widget build(BuildContext context) => NeuroCard(child: Column(children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 7),
        FittedBox(child: Text(value,
            textDirection: TextDirection.ltr,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
        const SizedBox(height: 3),
        Text(label, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ]));
}
