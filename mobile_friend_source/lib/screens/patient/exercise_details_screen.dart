import 'package:flutter/material.dart';

import '../../widgets/patient_page.dart';
import 'word_recall_screen.dart';

class ExerciseDetailsScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const ExerciseDetailsScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
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
                    color: color.withValues(alpha: .13),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 50,
                    color: color,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF4F3C38),
                  ),
                ),
              ),

              const SizedBox(height: 27),

              const NeuroCard(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الهدف العام',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF4F3C38),
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      'دعم مهارات الذاكرة والانتباه بطريقة بسيطة ومريحة.',
                      style: TextStyle(
                        height: 1.7,
                        color: Color(0xFF89736F),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              const NeuroCard(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'التعليمات',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF4F3C38),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. اقرأ التعليمات بهدوء.\n'
                      '2. خذ وقتك ولا تتعجل.\n'
                      '3. يمكنك طلب تلميح عند الحاجة.',
                      style: TextStyle(
                        height: 1.8,
                        color: Color(0xFF89736F),
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
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
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
                    backgroundColor:
                        const Color(0xFFB87585),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const WordRecallScreen(),
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
          color: const Color(0xFFEAD8DD),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFFB87585),
          ),
          const SizedBox(height: 6),
          Text(
            label,
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
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4F3C38),
            ),
          ),
        ],
      ),
    );
  }
}