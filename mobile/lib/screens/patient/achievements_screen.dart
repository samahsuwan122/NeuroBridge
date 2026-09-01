import 'package:flutter/material.dart';

import '../../widgets/patient_page.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final achievements = const [
      ('أول جلسة', 'أكملت أول جلسة تدريبية', Icons.flag_rounded, true),
      (
        '3 أيام متتالية',
        'استمررت بالتدريب ثلاثة أيام',
        Icons.local_fire_department_rounded,
        true
      ),
      ('10 تمارين', 'أكملت عشرة تمارين', Icons.psychology_alt_rounded, true),
      (
        'أسبوع جميل',
        'أكمل أسبوعًا من الالتزام',
        Icons.calendar_month_rounded,
        false
      ),
      ('شهر من الاستمرار', 'استمر لمدة شهر', Icons.emoji_events_rounded, false),
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
                      'إنجازاتي',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF35251C),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'كل إنجاز يعكس استمرارك، وليس منافسة مع الآخرين.',
                style: TextStyle(
                  height: 1.6,
                  color: Color(0xFF76665A),
                ),
              ),
              const SizedBox(height: 25),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: achievements.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: .95,
                ),
                itemBuilder: (_, index) {
                  final achievement = achievements[index];

                  final unlocked = achievement.$4;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: unlocked ? Colors.white : const Color(0xFFF4EEE5),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: unlocked
                            ? const Color(
                                0xFFD8C4A7,
                              )
                            : const Color(
                                0xFFE5DED3,
                              ),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 67,
                          height: 67,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: unlocked
                                ? const Color(
                                    0xFFE9D9C4,
                                  )
                                : const Color(
                                    0xFFE5DED3,
                                  ),
                          ),
                          child: Icon(
                            achievement.$3,
                            size: 32,
                            color: unlocked
                                ? const Color(
                                    0xFF4A3528,
                                  )
                                : const Color(
                                    0xFFB2A7A9,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          achievement.$1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: unlocked
                                ? const Color(
                                    0xFF35251C,
                                  )
                                : const Color(
                                    0xFF9F9290,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          achievement.$2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            height: 1.5,
                            color: unlocked
                                ? const Color(
                                    0xFF76665A,
                                  )
                                : const Color(
                                    0xFFAAA0A1,
                                  ),
                          ),
                        ),
                      ],
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
