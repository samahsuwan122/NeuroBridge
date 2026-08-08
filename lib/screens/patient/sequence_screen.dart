import 'package:flutter/material.dart';

import '../../widgets/patient_page.dart';
import 'exercise_result_screen.dart';

class SequenceScreen extends StatefulWidget {
  const SequenceScreen({super.key});

  @override
  State<SequenceScreen> createState() =>
      _SequenceScreenState();
}

class _SequenceScreenState
    extends State<SequenceScreen> {
  int? answer;

  void _finish() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseResultScreen(
          correctAnswers: answer == 4 ? 1 : 0,
          totalQuestions: 1,
          duration: '0:20',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = [3, 4, 5, 6];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PatientPage(
          child: Column(
            children: [
              const Text(
                'تسلسل الأرقام',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF4F3C38),
                ),
              ),

              const SizedBox(height: 35),

              const NeuroCard(
                color: Color(0xFFFFE9EF),
                child: Center(
                  child: Text(
                    '1   ،   2   ،   3   ،   ؟',
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF4F3C38),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: options.map((number) {
                  final selected =
                      answer == number;

                  return ChoiceChip(
                    selected: selected,
                    label: Text(
                      '$number',
                      style: const TextStyle(
                        fontSize: 19,
                      ),
                    ),
                    selectedColor:
                        const Color(0xFFFFE1E9),
                    onSelected: (_) {
                      setState(() {
                        answer = number;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton(
                  onPressed:
                      answer == null ? null : _finish,
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFB87585),
                  ),
                  child: const Text(
                    'تأكيد الإجابة',
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