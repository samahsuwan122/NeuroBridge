import 'package:flutter/material.dart';

import '../../widgets/patient_page.dart';
import 'exercise_result_screen.dart';

class CategorizationScreen extends StatefulWidget {
  const CategorizationScreen({super.key});

  @override
  State<CategorizationScreen> createState() =>
      _CategorizationScreenState();
}

class _CategorizationScreenState
    extends State<CategorizationScreen> {
  String? selectedCategory;

  final item = '🍎';

  void _finish() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseResultScreen(
          correctAnswers:
              selectedCategory == 'طعام' ? 1 : 0,
          totalQuestions: 1,
          duration: '0:25',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const categories = [
      ('طعام', Icons.restaurant_rounded),
      ('ملابس', Icons.checkroom_rounded),
      ('حيوانات', Icons.pets_rounded),
      ('أدوات منزلية', Icons.chair_alt_rounded),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PatientPage(
          child: Column(
            children: [
              const Text(
                'تصنيف العناصر',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF4F3C38),
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                '🍎',
                style: TextStyle(fontSize: 80),
              ),

              const SizedBox(height: 13),

              const Text(
                'إلى أي مجموعة ينتمي هذا العنصر؟',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4F3C38),
                ),
              ),

              const SizedBox(height: 25),

              ...categories.map(
                (category) => Padding(
                  padding:
                      const EdgeInsets.only(bottom: 10),
                  child: RadioListTile<String>(
                    value: category.$1,
                    groupValue: selectedCategory,
                    activeColor:
                        const Color(0xFFB87585),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                    tileColor: Colors.white,
                    secondary: Icon(category.$2),
                    title: Text(category.$1),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton(
                  onPressed: selectedCategory == null
                      ? null
                      : _finish,
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