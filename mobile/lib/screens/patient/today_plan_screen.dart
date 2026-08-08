import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/patient_page.dart';
import 'daily_session_screen.dart';

class TodayPlanScreen extends StatelessWidget {
  const TodayPlanScreen({super.key});

  static const rose = AppColors.primary;
  static const brown = AppColors.textPrimary;
  static const muted = AppColors.textSecondary;

  @override
  Widget build(BuildContext context) {
    final tasks = [
      (
        'تذكّر الكلمات',
        '5 دقائق',
        true,
        Icons.text_fields_rounded,
      ),
      (
        'استراحة قصيرة',
        '2 دقيقة',
        true,
        Icons.spa_outlined,
      ),
      (
        'مطابقة البطاقات',
        '6 دقائق',
        false,
        Icons.grid_view_rounded,
      ),
      (
        'ترتيب الأحداث',
        '5 دقائق',
        false,
        Icons.format_list_numbered_rounded,
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PatientPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context),
              const SizedBox(height: 22),
              NeuroCard(
                color: const Color(0xFFF1E7D8),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Expanded(
                          child: Text(
                            'إنجاز اليوم',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: brown,
                            ),
                          ),
                        ),
                        Text(
                          '50%',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: rose,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 13),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: const LinearProgressIndicator(
                        value: .5,
                        minHeight: 9,
                        backgroundColor: Color(0xFFE1D1BC),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          rose,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const PatientSectionTitle(
                title: 'خطة الجلسة',
              ),
              const SizedBox(height: 12),
              ...tasks.map(
                (task) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: 11,
                  ),
                  child: NeuroCard(
                    child: Row(
                      children: [
                        Container(
                          width: 49,
                          height: 49,
                          decoration: BoxDecoration(
                            color: task.$3
                                ? const Color(0xFFE8F2EC)
                                : const Color(0xFFF1E7D8),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            task.$4,
                            color: task.$3 ? const Color(0xFF78A087) : rose,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.$1,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: brown,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                task.$2,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          task.$3
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: task.$3
                              ? const Color(0xFF78A087)
                              : const Color(0xFFD2C2AE),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 13),
              NeuroCard(
                child: const Row(
                  children: [
                    Icon(
                      Icons.event_rounded,
                      color: Color(0xFF7895A4),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'موعد اليوم',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: brown,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'مراجعة مع الأخصائي • 4:30 مساءً',
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
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: rose,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DailySessionScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.play_arrow_rounded,
                  ),
                  label: const Text(
                    'متابعة جلسة اليوم',
                    style: TextStyle(
                      fontSize: 16,
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

  Widget _header(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_forward_ios_rounded,
          ),
        ),
        const SizedBox(width: 7),
        const Expanded(
          child: Text(
            'خطة اليوم',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: brown,
            ),
          ),
        ),
        const Icon(
          Icons.today_rounded,
          color: rose,
        ),
      ],
    );
  }
}
