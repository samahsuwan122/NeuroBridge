import 'package:flutter/material.dart';

import '../../widgets/patient_page.dart';
import 'today_plan_screen.dart';

class ExerciseResultScreen extends StatelessWidget {
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

  double get percentage {
    if (totalQuestions == 0) return 0;

    return correctAnswers / totalQuestions;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PatientPage(
          child: Column(
            children: [
              const SizedBox(height: 30),
              Container(
                width: 130,
                height: 130,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE8EE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.celebration_rounded,
                  size: 65,
                  color: Color(0xFF4A3528),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'أحسنت، أكملت التمرين! 🌷',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF35251C),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'كل محاولة هي خطوة إضافية في رحلة التدريب.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  height: 1.7,
                  color: Color(0xFF76665A),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: _ResultStat(
                      icon: Icons.task_alt_rounded,
                      value: '$correctAnswers / $totalQuestions',
                      label: 'إجابات صحيحة',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ResultStat(
                      icon: Icons.schedule_rounded,
                      value: duration,
                      label: 'مدة التمرين',
                    ),
                  ),
                ],
              ),
              if (extraText != null) ...[
                const SizedBox(height: 12),
                NeuroCard(
                  child: Center(
                    child: Text(
                      extraText!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF6D513F),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              NeuroCard(
                color: const Color(0xFFEAF4ED),
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      color: Color(0xFF71947A),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        percentage >= .7
                            ? 'تقدّم جميل مقارنة بمحاولتك السابقة. استمر بهدوء.'
                            : 'أكملت التمرين بنجاح. يمكنك المحاولة مجددًا عندما تكون مستعدًا.',
                        style: const TextStyle(
                          height: 1.6,
                          color: Color(0xFF5F7464),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.replay_rounded,
                  ),
                  label: const Text('المحاولة مجددًا'),
                ),
              ),
              const SizedBox(height: 11),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4A3528),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TodayPlanScreen(),
                      ),
                      (route) => route.isFirst,
                    );
                  },
                  child: const Text(
                    'العودة لخطة اليوم',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _ResultStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return NeuroCard(
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF4A3528),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF35251C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF76665A),
            ),
          ),
        ],
      ),
    );
  }
}
