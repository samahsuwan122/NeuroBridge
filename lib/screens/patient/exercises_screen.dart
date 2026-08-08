import 'package:flutter/material.dart';

import '../../widgets/patient_page.dart';
import 'exercise_details_screen.dart';

class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key});

  static const Color rose = Color(0xFFB87585);
  static const Color brown = Color(0xFF4F3C38);
  static const Color muted = Color(0xFF89736F);

  @override
  Widget build(BuildContext context) {
    final exercises = [
      _ExerciseItem(
        title: 'الذاكرة',
        subtitle: 'تمارين تذكّر الكلمات والصور',
        icon: Icons.memory_rounded,
        color: const Color(0xFFB87585),
        background: const Color(0xFFFFE9EF),
        goal: 'تنشيط الذاكرة قصيرة المدى وتذكّر المعلومات.',
        duration: '5 - 10 دقائق',
        level: 'متوسط',
      ),
      _ExerciseItem(
        title: 'الانتباه',
        subtitle: 'تدريبات على التركيز والملاحظة',
        icon: Icons.visibility_rounded,
        color: const Color(0xFF7895A4),
        background: const Color(0xFFEAF2F5),
        goal: 'دعم الانتباه والتركيز على التفاصيل.',
        duration: '5 دقائق',
        level: 'سهل',
      ),
      _ExerciseItem(
        title: 'التركيز',
        subtitle: 'مهام تتطلب تركيزًا تدريجيًا',
        icon: Icons.center_focus_strong_rounded,
        color: const Color(0xFF9D7BB0),
        background: const Color(0xFFF2EBF7),
        goal: 'تدريب القدرة على الاستمرار في المهمة دون تشتت.',
        duration: '6 - 8 دقائق',
        level: 'متوسط',
      ),
      _ExerciseItem(
        title: 'اللغة',
        subtitle: 'كلمات وصور وفهم لغوي',
        icon: Icons.translate_rounded,
        color: const Color(0xFFC79A62),
        background: const Color(0xFFFFF2DF),
        goal: 'دعم الربط بين الكلمات والمعاني والصور.',
        duration: '5 - 7 دقائق',
        level: 'سهل',
      ),
      _ExerciseItem(
        title: 'حل المشكلات',
        subtitle: 'مواقف بسيطة واختيار الحل',
        icon: Icons.lightbulb_outline_rounded,
        color: const Color(0xFF71947A),
        background: const Color(0xFFEAF4ED),
        goal: 'تدريب التفكير واختيار الحل الأنسب للمواقف اليومية.',
        duration: '7 دقائق',
        level: 'متوسط',
      ),
      _ExerciseItem(
        title: 'الترتيب والتخطيط',
        subtitle: 'ترتيب خطوات النشاط اليومي',
        icon: Icons.account_tree_outlined,
        color: const Color(0xFFC47B88),
        background: const Color(0xFFFFEDF2),
        goal: 'دعم القدرة على ترتيب الخطوات والتخطيط للمهام.',
        duration: '6 دقائق',
        level: 'متوسط',
      ),
      _ExerciseItem(
        title: 'الإدراك البصري',
        subtitle: 'صور وأشكال ومطابقة بصرية',
        icon: Icons.image_search_rounded,
        color: const Color(0xFF8296C4),
        background: const Color(0xFFEEF2FA),
        goal: 'تدريب التمييز بين الصور والأشكال والعناصر.',
        duration: '5 دقائق',
        level: 'سهل',
      ),
      _ExerciseItem(
        title: 'سرعة الاستجابة',
        subtitle: 'اختيارات سريعة بدون ضغط',
        icon: Icons.bolt_rounded,
        color: const Color(0xFFD29655),
        background: const Color(0xFFFFF2E2),
        goal: 'تدريب الاستجابة للمحفزات بطريقة مريحة ومتدرجة.',
        duration: '4 دقائق',
        level: 'سهل',
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: PatientPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (Navigator.canPop(context))
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_forward_ios_rounded,
                    ),
                  ),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'جميع التمارين',
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                          color: brown,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'اختر المهارة التي ترغب بالتدرب عليها اليوم.',
                        style: TextStyle(
                          fontSize: 12,
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: exercises.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.05,
              ),
              itemBuilder: (_, index) {
                final exercise = exercises[index];

                return _ExerciseCard(
                  item: exercise,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExerciseDetailsScreen(
                          title: exercise.title,
                          goal: exercise.goal,
                          duration: exercise.duration,
                          level: exercise.level,
                          icon: exercise.icon,
                          color: exercise.color,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color background;
  final String goal;
  final String duration;
  final String level;

  const _ExerciseItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.background,
    required this.goal,
    required this.duration,
    required this.level,
  });
}

class _ExerciseCard extends StatelessWidget {
  final _ExerciseItem item;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
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
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: item.background,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: 27,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF4F3C38),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                item.subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  height: 1.4,
                  color: Color(0xFF89736F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}