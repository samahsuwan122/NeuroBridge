import 'package:flutter/material.dart';

import '../../models/exercise.dart';
import '../../widgets/patient_page.dart';
import 'exercise_details_screen.dart';

class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final skills = [
      ('الذاكرة', Icons.memory_rounded, Color(0xFF4A3528)),
      ('الانتباه', Icons.visibility_rounded, Color(0xFF7895A4)),
      ('التركيز', Icons.center_focus_strong_rounded, Color(0xFF9D7BB0)),
      ('اللغة', Icons.translate_rounded, Color(0xFFC79A62)),
      ('حل المشكلات', Icons.lightbulb_outline_rounded, Color(0xFF7D9B82)),
      ('الترتيب والتخطيط', Icons.account_tree_outlined, Color(0xFFC37B74)),
      ('الإدراك البصري', Icons.image_search_rounded, Color(0xFF7C8FB5)),
      ('سرعة الاستجابة', Icons.bolt_rounded, Color(0xFFD39A5D)),
    ];

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
                    icon: const Icon(
                      Icons.arrow_forward_ios_rounded,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'جميع التمارين',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF35251C),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'اختر المهارة التي ترغب بالتدرب عليها اليوم.',
                style: TextStyle(
                  height: 1.6,
                  color: Color(0xFF76665A),
                ),
              ),
              const SizedBox(height: 25),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: skills.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 13,
                  crossAxisSpacing: 13,
                  childAspectRatio: 1.12,
                ),
                itemBuilder: (_, index) {
                  final skill = skills[index];

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExerciseDetailsScreen(
                              exercise: ExerciseCatalog.all[index],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(17),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .80),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: const Color(
                              0xFFE4D8C8,
                            ),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: skill.$3.withValues(
                                  alpha: .13,
                                ),
                                borderRadius: BorderRadius.circular(
                                  18,
                                ),
                              ),
                              child: Icon(
                                skill.$2,
                                color: skill.$3,
                                size: 29,
                              ),
                            ),
                            const SizedBox(height: 13),
                            Text(
                              skill.$1,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: Color(
                                  0xFF35251C,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
