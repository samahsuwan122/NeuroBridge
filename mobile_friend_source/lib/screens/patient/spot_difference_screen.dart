import 'package:flutter/material.dart';

import '../../widgets/patient_page.dart';
import 'exercise_result_screen.dart';

class SpotDifferenceScreen extends StatefulWidget {
  const SpotDifferenceScreen({super.key});

  @override
  State<SpotDifferenceScreen> createState() =>
      _SpotDifferenceScreenState();
}

class _SpotDifferenceScreenState
    extends State<SpotDifferenceScreen> {
  int found = 0;
  bool showHint = false;

  void _foundDifference() {
    if (found >= 3) return;

    setState(() {
      found++;
    });

    if (found == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const ExerciseResultScreen(
            correctAnswers: 3,
            totalQuestions: 3,
            duration: '2:05',
          ),
        ),
      );
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
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'اكتشاف الاختلاف',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF4F3C38),
                      ),
                    ),
                  ),
                  Text(
                    '$found / 3',
                    style: const TextStyle(
                      color: Color(0xFFB87585),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              const Text(
                'اضغط على الاختلافات التي تلاحظها. لا يوجد وقت محدد.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF89736F),
                ),
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(
                    child: _DemoDifferenceImage(
                      onTap: _foundDifference,
                      label: 'الصورة 1',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DemoDifferenceImage(
                      onTap: _foundDifference,
                      label: 'الصورة 2',
                    ),
                  ),
                ],
              ),

              if (showHint) ...[
                const SizedBox(height: 18),
                const NeuroCard(
                  color: Color(0xFFFFF1DD),
                  child: Text(
                    'تلميح: ركّز على اللون وعدد العناصر ومكانها.',
                    style: TextStyle(
                      color: Color(0xFF806544),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 22),

              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    showHint = true;
                  });
                },
                icon:
                    const Icon(Icons.lightbulb_outline),
                label: const Text('أعطني تلميحًا'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoDifferenceImage extends StatelessWidget {
  final VoidCallback onTap;
  final String label;

  const _DemoDifferenceImage({
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 260,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFEAD8DD),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🏠  🌳\n\n☀️    🐦\n\n🌷 🌷 🌷',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 27,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF89736F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}