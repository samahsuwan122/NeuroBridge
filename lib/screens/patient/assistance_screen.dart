import 'package:flutter/material.dart';

import '../../widgets/patient_page.dart';
import '../help_center_screen.dart';

class AssistanceScreen extends StatelessWidget {
  const AssistanceScreen({super.key});

  static const rose = Color(0xFFB87585);
  static const brown = Color(0xFF4F3C38);
  static const muted = Color(0xFF89736F);

  void _showSuccess(
    BuildContext context,
    String text,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_forward_ios_rounded,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'المساعدة السريعة',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        color: brown,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              const Text(
                'اختر الطريقة التي تناسبك للحصول على مساعدة.',
                style: TextStyle(
                  height: 1.6,
                  color: muted,
                ),
              ),

              const SizedBox(height: 28),

              _AssistanceCard(
                icon: Icons.phone_in_talk_rounded,
                title: 'الاتصال بالمرافق',
                subtitle:
                    'الاتصال بأحد أفراد العائلة المرتبطين',
                color: const Color(0xFF7895A4),
                onTap: () {
                  _showSuccess(
                    context,
                    'سيتم فتح الاتصال بالمرافق عند ربط جهات الاتصال.',
                  );
                },
              ),

              const SizedBox(height: 13),

              _AssistanceCard(
                icon: Icons.favorite_outline_rounded,
                title: 'أحتاج مساعدة',
                subtitle:
                    'إرسال رسالة قصيرة إلى المرافق',
                color: rose,
                onTap: () {
                  _showSuccess(
                    context,
                    'تم إرسال "أحتاج مساعدة" تجريبيًا إلى المرافق.',
                  );
                },
              ),

              const SizedBox(height: 13),

              _AssistanceCard(
                icon: Icons.menu_book_outlined,
                title: 'كيف أستخدم التطبيق؟',
                subtitle:
                    'فتح مركز المساعدة والتعليمات',
                color: const Color(0xFFC79A62),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const HelpCenterScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 13),

              _AssistanceCard(
                icon: Icons.support_agent_rounded,
                title: 'التواصل مع الدعم',
                subtitle:
                    'الحصول على مساعدة تقنية حول التطبيق',
                color: const Color(0xFF9D7BB0),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const HelpCenterScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),

              NeuroCard(
                color: const Color(0xFFFFF2DF),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFFC49152),
                    ),
                    SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        'هذه الشاشة للمساعدة داخل التطبيق والتواصل مع الأشخاص الداعمين. ليست خدمة طوارئ طبية.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.7,
                          color: Color(0xFF7C654A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssistanceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AssistanceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NeuroCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: .12,
              ),
              borderRadius: BorderRadius.circular(19),
            ),
            child: Icon(
              icon,
              size: 30,
              color: color,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF4F3C38),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: Color(0xFF89736F),
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: Color(0xFFB5A2A6),
          ),
        ],
      ),
    );
  }
}