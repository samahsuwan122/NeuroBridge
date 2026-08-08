import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/patient_page.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  final String title;
  final String specialist;
  final String date;
  final String time;
  final String place;
  final bool online;

  const AppointmentDetailsScreen({
    super.key,
    required this.title,
    required this.specialist,
    required this.date,
    required this.time,
    required this.place,
    required this.online,
  });

  static const rose = AppColors.primary;
  static const brown = AppColors.textPrimary;
  static const muted = AppColors.textSecondary;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PatientPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_forward_ios_rounded,
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1E7D8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    online
                        ? Icons.videocam_outlined
                        : Icons.medical_services_outlined,
                    size: 45,
                    color: rose,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: brown,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  specialist,
                  style: const TextStyle(
                    color: muted,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _AppointmentInfo(
                icon: Icons.calendar_today_outlined,
                title: 'التاريخ',
                value: date,
              ),
              const SizedBox(height: 11),
              _AppointmentInfo(
                icon: Icons.schedule_rounded,
                title: 'الوقت',
                value: time,
              ),
              const SizedBox(height: 11),
              _AppointmentInfo(
                icon: online ? Icons.link_rounded : Icons.location_on_outlined,
                title: online ? 'نوع الموعد' : 'موقع العيادة',
                value: place,
              ),
              const SizedBox(height: 22),
              const PatientSectionTitle(
                title: 'تعليمات الاستعداد',
              ),
              const SizedBox(height: 10),
              const NeuroCard(
                child: Text(
                  '• حاول الحضور قبل الموعد بـ10 دقائق.\n'
                  '• أحضر أي ملاحظات تريد مناقشتها.\n'
                  '• خذ استراحة مناسبة قبل الجلسة.\n'
                  '• لا تتردد في طلب المساعدة من مرافقك.',
                  style: TextStyle(
                    height: 1.9,
                    color: muted,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (!online)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'سيتم فتح موقع العيادة عند ربط الخرائط.',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.location_on_outlined,
                    ),
                    label: const Text(
                      'عرض موقع العيادة',
                    ),
                  ),
                ),
              if (online)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: rose,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'سيتم فتح رابط الجلسة عند ربط الـBackend.',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.videocam_rounded,
                    ),
                    label: const Text(
                      'فتح رابط الجلسة',
                    ),
                  ),
                ),
              const SizedBox(height: 11),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'سيتم إضافة الموعد إلى التقويم عند ربط تقويم الهاتف.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.event_available_outlined,
                  ),
                  label: const Text(
                    'إضافة إلى تقويم الهاتف',
                  ),
                ),
              ),
              const SizedBox(height: 11),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'تم تسجيل طلب تعديل الموعد بشكل تجريبي.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.edit_calendar_outlined,
                  ),
                  label: const Text(
                    'طلب تعديل الموعد',
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

class _AppointmentInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _AppointmentInfo({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return NeuroCard(
      child: Row(
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color: const Color(0xFFF1E7D8),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF4A3528),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF76665A),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF35251C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
