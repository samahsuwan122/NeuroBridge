import 'package:flutter/material.dart';

import '../../widgets/patient_page.dart';
import 'activity_history_screen.dart';
import 'achievements_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  static const rose = Color(0xFFB87585);
  static const brown = Color(0xFF4F3C38);
  static const muted = Color(0xFF89736F);

  @override
  Widget build(BuildContext context) {
    final weeklyValues = [
      .55,
      .75,
      .40,
      .85,
      .65,
      .90,
      .70,
    ];

    final days = [
      'س',
      'ح',
      'ن',
      'ث',
      'ر',
      'خ',
      'ج',
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
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تقدّمي',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: brown,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'تابع نشاطك وتقدّمك بطريقة بسيطة ومشجعة.',
                          style: TextStyle(
                            fontSize: 13,
                            color: muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              const Row(
                children: [
                  Expanded(
                    child: _ProgressStat(
                      icon: Icons.task_alt_rounded,
                      value: '18',
                      label: 'جلسة مكتملة',
                    ),
                  ),
                  SizedBox(width: 11),
                  Expanded(
                    child: _ProgressStat(
                      icon: Icons.local_fire_department_rounded,
                      value: '7',
                      label: 'أيام التزام',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 11),

              const Row(
                children: [
                  Expanded(
                    child: _ProgressStat(
                      icon: Icons.timer_outlined,
                      value: '3.2',
                      label: 'ساعة تدريب',
                    ),
                  ),
                  SizedBox(width: 11),
                  Expanded(
                    child: _ProgressStat(
                      icon: Icons.insights_rounded,
                      value: '78%',
                      label: 'متوسط الأداء',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              const PatientSectionTitle(
                title: 'نشاط هذا الأسبوع',
              ),

              const SizedBox(height: 12),

              NeuroCard(
                child: SizedBox(
                  height: 190,
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.end,
                    children: List.generate(
                      weeklyValues.length,
                      (index) {
                        return Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 4,
                            ),
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment:
                                        Alignment.bottomCenter,
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(
                                        milliseconds: 400,
                                      ),
                                      height:
                                          130 *
                                              weeklyValues[
                                                  index],
                                      width: 23,
                                      decoration:
                                          BoxDecoration(
                                        color: rose,
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  days[index],
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const PatientSectionTitle(
                title: 'المهارات التي تدربت عليها',
              ),

              const SizedBox(height: 12),

              const Wrap(
                spacing: 9,
                runSpacing: 9,
                children: [
                  _SkillChip(
                    text: 'الذاكرة',
                    icon: Icons.memory_rounded,
                  ),
                  _SkillChip(
                    text: 'التركيز',
                    icon:
                        Icons.center_focus_strong_rounded,
                  ),
                  _SkillChip(
                    text: 'الانتباه',
                    icon: Icons.visibility_rounded,
                  ),
                  _SkillChip(
                    text: 'اللغة',
                    icon: Icons.translate_rounded,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              NeuroCard(
                color: const Color(0xFFEAF4ED),
                child: const Row(
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      color: Color(0xFF71947A),
                      size: 28,
                    ),
                    SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'استمرار جميل هذا الأسبوع',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: brown,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'استمر بنفس الوتيرة المريحة. الأداء يُستخدم للمتابعة وليس للتشخيص.',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.6,
                              color: Color(0xFF647367),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              _NavigationCard(
                icon: Icons.history_rounded,
                title: 'سجل النشاط',
                subtitle:
                    'شاهد الجلسات والتمارين السابقة',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const ActivityHistoryScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 11),

              _NavigationCard(
                icon: Icons.emoji_events_outlined,
                title: 'الإنجازات',
                subtitle:
                    'شاهد الشارات التي حصلت عليها',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AchievementsScreen(),
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

class _ProgressStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _ProgressStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return NeuroCard(
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFFB87585),
            size: 25,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF4F3C38),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF89736F),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String text;
  final IconData icon;

  const _SkillChip({
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE9EF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 17,
            color: const Color(0xFFB87585),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF6C5652),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NavigationCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NeuroCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE9EF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFB87585),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF4F3C38),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF89736F),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 15,
            color: Color(0xFFB7A3A7),
          ),
        ],
      ),
    );
  }
}