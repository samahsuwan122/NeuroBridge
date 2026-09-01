import 'package:flutter/material.dart';

import '../../widgets/patient_page.dart';
import 'exercise_result_screen.dart';

class EmotionRecognitionScreen extends StatefulWidget {
  const EmotionRecognitionScreen({super.key});

  @override
  State<EmotionRecognitionScreen> createState() =>
      _EmotionRecognitionScreenState();
}

class _EmotionRecognitionScreenState extends State<EmotionRecognitionScreen> {
  String? selected;

  @override
  Widget build(BuildContext context) {
    final emotions = [
      ('سعيد', '😊'),
      ('حزين', '😢'),
      ('خائف', '😨'),
      ('غاضب', '😠'),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PatientPage(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_forward_ios_rounded),
                  ),
                  const Expanded(
                    child: Text(
                      'التعرف على المشاعر',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF35251C),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const NeuroCard(
                color: Color(0xFFFFF2DF),
                child: Text(
                  'هذا التمرين ميزة تدريبية متقدمة ويُستخدم عند ملاءمته لخطة المستخدم وإشراف المختص.',
                  style: TextStyle(
                    height: 1.6,
                    color: Color(0xFF7A6243),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                '😊',
                style: TextStyle(fontSize: 90),
              ),
              const SizedBox(height: 15),
              const Text(
                'ما الشعور الذي تعبّر عنه هذه الصورة؟',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF35251C),
                ),
              ),
              const SizedBox(height: 25),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: emotions.map((emotion) {
                  return ChoiceChip(
                    selected: selected == emotion.$1,
                    label: Text(
                      '${emotion.$2} ${emotion.$1}',
                    ),
                    onSelected: (_) {
                      setState(() {
                        selected = emotion.$1;
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
                  onPressed: selected == null
                      ? null
                      : () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExerciseResultScreen(
                                correctAnswers: selected == 'سعيد' ? 1 : 0,
                                totalQuestions: 1,
                                duration: '0:18',
                              ),
                            ),
                          );
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4A3528),
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
