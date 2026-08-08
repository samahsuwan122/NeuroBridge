import 'package:flutter/material.dart';

import '../../widgets/patient_page.dart';
import 'exercise_result_screen.dart';

class AudioMemoryScreen extends StatefulWidget {
  const AudioMemoryScreen({super.key});

  @override
  State<AudioMemoryScreen> createState() =>
      _AudioMemoryScreenState();
}

class _AudioMemoryScreenState
    extends State<AudioMemoryScreen> {
  bool played = false;
  double speed = 1;
  String? selected;

  void _play() {
    setState(() {
      played = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تشغيل تجريبي بسرعة ${speed.toStringAsFixed(1)}x: "كتاب، شجرة، قمر"',
        ),
      ),
    );
  }

  void _finish() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseResultScreen(
          correctAnswers:
              selected == 'كتاب، شجرة، قمر' ? 1 : 0,
          totalQuestions: 1,
          duration: '0:40',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = [
      'كتاب، شجرة، قمر',
      'كتاب، سيارة، قمر',
      'بحر، شجرة، ساعة',
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PatientPage(
          child: Column(
            children: [
              const Text(
                'تمرين الاستماع',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF4F3C38),
                ),
              ),

              const SizedBox(height: 30),

              Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFE9EF),
                ),
                child: IconButton(
                  onPressed: _play,
                  icon: Icon(
                    played
                        ? Icons.replay_rounded
                        : Icons.play_arrow_rounded,
                    size: 52,
                    color: const Color(0xFFB87585),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'استمع للكلمات ثم اختر ما سمعته.',
                style: TextStyle(
                  color: Color(0xFF89736F),
                ),
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  const Text('سرعة القراءة'),
                  Expanded(
                    child: Slider(
                      value: speed,
                      min: .5,
                      max: 1.5,
                      divisions: 2,
                      activeColor:
                          const Color(0xFFB87585),
                      label:
                          '${speed.toStringAsFixed(1)}x',
                      onChanged: (value) {
                        setState(() {
                          speed = value;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              ...options.map(
                (option) => RadioListTile<String>(
                  value: option,
                  groupValue: selected,
                  activeColor:
                      const Color(0xFFB87585),
                  title: Text(option),
                  onChanged: played
                      ? (value) {
                          setState(() {
                            selected = value;
                          });
                        }
                      : null,
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton(
                  onPressed:
                      selected == null ? null : _finish,
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFB87585),
                  ),
                  child: const Text('متابعة'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}