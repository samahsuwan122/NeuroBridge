import 'package:flutter/material.dart';

import '../../models/exercise.dart';
import '../../widgets/patient_page.dart';
import 'exercise_play_resolver.dart';

class ExerciseDetailsScreen extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailsScreen({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PatientPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_forward_ios_rounded,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 105,
                  height: 105,
                  decoration: BoxDecoration(
                    color: exercise.color.withValues(alpha: .13),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    exercise.icon,
                    size: 50,
                    color: exercise.color,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Center(
                child: Text(
                  exercise.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF35251C),
                  ),
                ),
              ),
              const SizedBox(height: 27),
              const NeuroCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الهدف العام',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF35251C),
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      'دعم مهارات الذاكرة والانتباه بطريقة بسيطة ومريحة.',
                      style: TextStyle(
                        height: 1.7,
                        color: Color(0xFF76665A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const NeuroCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'التعليمات',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF35251C),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. اقرأ التعليمات بهدوء.\n'
                      '2. خذ وقتك ولا تتعجل.\n'
                      '3. يمكنك طلب تلميح عند الحاجة.',
                      style: TextStyle(
                        height: 1.8,
                        color: Color(0xFF76665A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(
                    child: _InfoBox(
                      icon: Icons.signal_cellular_alt_rounded,
                      label: 'المستوى',
                      value: 'متوسط',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _InfoBox(
                      icon: Icons.schedule_rounded,
                      label: 'المدة',
                      value: '5 دقائق',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _InfoBox(
                      icon: Icons.volume_up_outlined,
                      label: 'الصوت',
                      value: 'اختياري',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'سيتم إضافة القراءة الصوتية لاحقًا.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.volume_up_rounded,
                  ),
                  label: const Text(
                    'سماع التعليمات',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4A3528),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      exercisePlayRoute(exercise),
                    );
                  },
                  icon: const Icon(
                    Icons.play_arrow_rounded,
                  ),
                  label: const Text(
                    'ابدأ التمرين',
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

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoBox({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .75),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFE4D8C8),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF4A3528),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF76665A),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF35251C),
            ),
          ),
        ],
      ),
    );
  }
}
