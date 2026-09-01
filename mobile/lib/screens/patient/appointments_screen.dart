import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/patient_page.dart';
import 'appointment_details_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  String selectedTab = 'القادمة';

  static const Color rose = AppColors.primary;
  static const Color brown = AppColors.textPrimary;
  static const Color muted = AppColors.textSecondary;

  final upcoming = const [
    (
      'جلسة متابعة',
      'د. أحمد خالد',
      'الخميس 6 أغسطس',
      '10:00 صباحًا',
      'عيادة NeuroCare',
      false
    ),
    (
      'جلسة علاج معرفي',
      'د. سارة محمود',
      'الأحد 9 أغسطس',
      '12:30 ظهرًا',
      'جلسة أونلاين',
      true
    ),
  ];

  final previous = const [
    (
      'جلسة متابعة',
      'د. أحمد خالد',
      '30 يوليو',
      '10:00 صباحًا',
      'عيادة NeuroCare',
      false
    ),
    (
      'جلسة علاج معرفي',
      'د. سارة محمود',
      '24 يوليو',
      '12:30 ظهرًا',
      'جلسة أونلاين',
      true
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final appointments = selectedTab == 'القادمة' ? upcoming : previous;

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
                      'المواعيد',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        color: brown,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: rose,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1E9DD),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _TabButton(
                        text: 'القادمة',
                        selected: selectedTab == 'القادمة',
                        onTap: () {
                          setState(() {
                            selectedTab = 'القادمة';
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: _TabButton(
                        text: 'السابقة',
                        selected: selectedTab == 'السابقة',
                        onTap: () {
                          setState(() {
                            selectedTab = 'السابقة';
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              ...appointments.map(
                (appointment) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: 13,
                  ),
                  child: NeuroCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AppointmentDetailsScreen(
                            title: appointment.$1,
                            specialist: appointment.$2,
                            date: appointment.$3,
                            time: appointment.$4,
                            place: appointment.$5,
                            online: appointment.$6,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 57,
                          height: 57,
                          decoration: BoxDecoration(
                            color: appointment.$6
                                ? const Color(0xFFEAF2F5)
                                : const Color(0xFFF1E7D8),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            appointment.$6
                                ? Icons.videocam_outlined
                                : Icons.medical_services_outlined,
                            color:
                                appointment.$6 ? const Color(0xFF7895A4) : rose,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment.$1,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: brown,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                appointment.$2,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: muted,
                                ),
                              ),
                              const SizedBox(height: 9),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 15,
                                    color: muted,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    appointment.$3,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: muted,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.schedule_rounded,
                                    size: 15,
                                    color: muted,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    appointment.$4,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: muted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 7),
                              Row(
                                children: [
                                  Icon(
                                    appointment.$6
                                        ? Icons.link_rounded
                                        : Icons.location_on_outlined,
                                    size: 15,
                                    color: rose,
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      appointment.$5,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: rose,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 15,
                          color: Color(0xFFB4A1A5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (selectedTab == 'القادمة') ...[
                const SizedBox(height: 16),
                NeuroCard(
                  color: const Color(0xFFEAF4ED),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.notifications_active_outlined,
                        color: Color(0xFF71947A),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'سنذكّرك قبل موعدك القادم بوقت مناسب.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.6,
                            color: Color(0xFF647367),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: selected ? const Color(0xFF6D513F) : const Color(0xFF76665A),
          ),
        ),
      ),
    );
  }
}
