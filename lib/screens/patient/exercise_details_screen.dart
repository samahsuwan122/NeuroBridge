import 'package:flutter/material.dart';

import '../../widgets/patient_page.dart';

class ExerciseDetailsScreen extends StatelessWidget {
  final String title;
  final String goal;
  final String duration;
  final String level;
  final IconData icon;
  final Color color;

  const ExerciseDetailsScreen({
    super.key,
    required this.title,
    required this.goal,
    required this.duration,
    required this.level,
    required this.icon,
    required this.color,
  });

  static const Color brown = Color(0xFF4F3C38);
  static const Color muted = Color(0xFF89736F);
  static const Color rose = Color(0xFFB87585);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PatientPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_forward_ios_rounded,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'تفاصيل التمرين',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: brown,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),

              const SizedBox(height: 25),

              Center(
                child: Container(
                  width: 105,
                  height: 105,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 50,
                    color: color,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    color: brown,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              NeuroCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.flag_outlined,
                          color: rose,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'هدف التمرين',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: brown,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      goal,
                      style: const TextStyle(
                        height: 1.7,
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.signal_cellular_alt_rounded,
                      title: 'المستوى',
                      value: level,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.schedule_rounded,
                      title: 'المدة',
                      value: duration,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              const NeuroCard(
                child: Row(
                  children: [
                    Icon(
                      Icons.volume_up_outlined,
                      color: rose,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'التعليمات الصوتية',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: brown,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'يمكنك سماع التعليمات قبل بدء التمرين.',
                            style: TextStyle(
                              fontSize: 11,
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.play_circle_outline_rounded,
                      color: rose,
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
                        color: brown,
                      ),
                    ),
                    SizedBox(height: 9),
                    Text(
                      '1. اقرأ التعليمات بهدوء.\n'
                      '2. خذ وقتك ولا تستعجل.\n'
                      '3. يمكنك أخذ استراحة متى احتجت.\n'
                      '4. الهدف هو التدريب والاستمرار وليس الحصول على نتيجة مثالية.',
                      style: TextStyle(
                        height: 1.8,
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 56),
                    backgroundColor: rose,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'سيتم الآن بدء تمرين $title',
                        ),
                      ),
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

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return NeuroCard(
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFFB87585),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF89736F),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Color(0xFF4F3C38),
            ),
          ),
        ],
      ),
    );
  }
}