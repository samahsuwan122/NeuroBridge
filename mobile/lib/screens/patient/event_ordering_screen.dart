import 'package:flutter/material.dart';

import '../../widgets/patient_page.dart';
import 'exercise_result_screen.dart';

class EventOrderingScreen extends StatefulWidget {
  const EventOrderingScreen({super.key});

  @override
  State<EventOrderingScreen> createState() => _EventOrderingScreenState();
}

class _EventOrderingScreenState extends State<EventOrderingScreen> {
  final List<String> correctOrder = [
    'غلي الماء',
    'وضع الشاي في الكوب',
    'صب الماء',
    'تقديم الكوب',
  ];

  late List<String> items;

  @override
  void initState() {
    super.initState();

    items = [
      'صب الماء',
      'تقديم الكوب',
      'غلي الماء',
      'وضع الشاي في الكوب',
    ];
  }

  void _check() {
    int correct = 0;

    for (int i = 0; i < items.length; i++) {
      if (items[i] == correctOrder[i]) {
        correct++;
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseResultScreen(
          correctAnswers: correct,
          totalQuestions: items.length,
          duration: '1:20',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                  const Expanded(
                    child: Text(
                      'ترتيب الأحداث',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF35251C),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'رتّب خطوات تحضير كوب الشاي.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF35251C),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'اسحب العناصر للأعلى أو للأسفل لوضعها بالترتيب الصحيح.',
                style: TextStyle(
                  height: 1.6,
                  color: Color(0xFF76665A),
                ),
              ),
              const SizedBox(height: 22),
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                onReorderItem: (oldIndex, newIndex) {
                  setState(() {
                    final item = items.removeAt(oldIndex);

                    items.insert(newIndex, item);
                  });
                },
                itemBuilder: (_, index) {
                  return Container(
                    key: ValueKey(items[index]),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFE4D8C8),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFFF1E7D8),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Color(0xFF4A3528),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Text(
                            items[index],
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF35251C),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.drag_handle_rounded,
                          color: Color(0xFFA6928E),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
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
                  onPressed: _check,
                  child: const Text(
                    'تحقق من الترتيب',
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
