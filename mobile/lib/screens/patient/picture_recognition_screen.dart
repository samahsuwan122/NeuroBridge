import 'package:flutter/material.dart';

import '../../widgets/patient_page.dart';
import 'exercise_result_screen.dart';

class PictureRecognitionScreen extends StatefulWidget {
  const PictureRecognitionScreen({super.key});

  @override
  State<PictureRecognitionScreen> createState() =>
      _PictureRecognitionScreenState();
}

class _PictureRecognitionScreenState extends State<PictureRecognitionScreen> {
  String? selected;

  final options = const {
    '🍎': 'تفاحة',
    '🚗': 'سيارة',
    '🐱': 'قطة',
    '🌳': 'شجرة',
  };

  void _finish() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseResultScreen(
          correctAnswers: selected == '🍎' ? 1 : 0,
          totalQuestions: 1,
          duration: '0:30',
        ),
      ),
    );
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
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_forward_ios_rounded),
                  ),
                  const Expanded(
                    child: Text(
                      'اختيار الصورة الصحيحة',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF35251C),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'اختر صورة: تفاحة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF6D513F),
                ),
              ),
              const SizedBox(height: 25),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: options.entries.map((entry) {
                  final active = selected == entry.key;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selected = entry.key;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: active ? const Color(0xFFF1E7D8) : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: active
                              ? const Color(0xFF4A3528)
                              : const Color(0xFFE4D8C8),
                          width: active ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 55,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            entry.value,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF35251C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton(
                  onPressed: selected == null ? null : _finish,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4A3528),
                  ),
                  child: const Text(
                    'تأكيد الاختيار',
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
