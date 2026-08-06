import 'package:flutter/material.dart';

import '../../widgets/caregiver_ui.dart';

import 'add_memory_screen.dart';
import 'caregiver_alerts_screen.dart';
import 'caregiver_guide_screen.dart';
import 'caregiver_profile_screen.dart';
import 'caregiver_wellbeing_screen.dart';
import 'family_appointments_screen.dart';
import 'family_memory_album_screen.dart';
import 'family_permissions_screen.dart';
import 'family_progress_screen.dart';
import 'link_patient_screen.dart';
import 'patient_activity_screen.dart';
import 'patient_summary_screen.dart';
import 'patient_switcher_screen.dart';
import 'reminder_management_screen.dart';
import 'send_encouragement_screen.dart';

class CaregiverHomeScreen extends StatelessWidget {
  const CaregiverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: CaregiverPage(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'أهلًا ليلى 🌷',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight:
                                FontWeight.w900,
                            color:
                                CaregiverColors.brown,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'دعمك الهادئ يصنع فرقًا جميلًا.',
                          style: TextStyle(
                            color:
                                CaregiverColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    tooltip: 'حسابي',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const CaregiverProfileScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.account_circle_outlined,
                      color: CaregiverColors.rose,
                      size: 30,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              CaregiverCard(
                color: const Color(0xFFFFE9EF),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const PatientSwitcherScreen(),
                    ),
                  );
                },
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person_rounded,
                        color: CaregiverColors.rose,
                        size: 33,
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'المريض الحالي',
                            style: TextStyle(
                              fontSize: 11,
                              color:
                                  CaregiverColors.muted,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'سامي أحمد',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.w900,
                              color:
                                  CaregiverColors.brown,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'نشط اليوم',
                            style: TextStyle(
                              color:
                                  CaregiverColors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.swap_horiz_rounded,
                      color: CaregiverColors.rose,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 17),

              const CaregiverCard(
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: CaregiverColors.green,
                      size: 30,
                    ),
                    SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'جلسة اليوم',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.w900,
                              color:
                                  CaregiverColors.brown,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'أكمل سامي جلسة اليوم بنسبة 100%',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  CaregiverColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'وصول سريع',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: CaregiverColors.brown,
                ),
              ),

              const SizedBox(height: 13),

              GridView.count(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  _HomeAction(
                    icon: Icons.favorite_rounded,
                    title: 'إرسال تشجيع',
                    color: CaregiverColors.rose,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const SendEncouragementScreen(),
                        ),
                      );
                    },
                  ),
                  _HomeAction(
                    icon: Icons.add_photo_alternate_outlined,
                    title: 'إضافة ذكرى',
                    color: CaregiverColors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AddMemoryScreen(),
                        ),
                      );
                    },
                  ),
                  _HomeAction(
                    icon: Icons.insights_rounded,
                    title: 'التقدّم',
                    color: CaregiverColors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const FamilyProgressScreen(),
                        ),
                      );
                    },
                  ),
                  _HomeAction(
                    icon: Icons.calendar_month_rounded,
                    title: 'المواعيد',
                    color: CaregiverColors.gold,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const FamilyAppointmentsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 25),

              CaregiverMenuTile(
                icon: Icons.summarize_outlined,
                title: 'ملخص سامي',
                subtitle:
                    'جلسة اليوم والالتزام الأسبوعي والموعد القادم',
                color: CaregiverColors.rose,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const PatientSummaryScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              CaregiverMenuTile(
                icon: Icons.history_rounded,
                title: 'آخر النشاط',
                subtitle:
                    'آخر التمارين والجلسات المكتملة',
                color: CaregiverColors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const PatientActivityScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              CaregiverMenuTile(
                icon: Icons.notifications_active_outlined,
                title: 'التنبيهات المهمة',
                subtitle:
                    'موعد غدًا • 3 أيام متتالية',
                color: CaregiverColors.gold,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const CaregiverAlertsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              CaregiverMenuTile(
                icon: Icons.notifications_none_rounded,
                title: 'إدارة التذكيرات',
                subtitle:
                    'التمرين والمواعيد والأنشطة اليومية',
                color: CaregiverColors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const ReminderManagementScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              CaregiverMenuTile(
                icon: Icons.photo_library_outlined,
                title: 'ألبوم الذكريات',
                subtitle:
                    'إدارة الصور والذكريات العائلية',
                color: CaregiverColors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const FamilyMemoryAlbumScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              CaregiverMenuTile(
                icon: Icons.link_rounded,
                title: 'ربط مريض',
                subtitle:
                    'رمز دعوة أو QR أو طلب ارتباط',
                color: CaregiverColors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const LinkPatientScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 25),

              const Text(
                'لك أنت أيضًا',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: CaregiverColors.brown,
                ),
              ),

              const SizedBox(height: 13),

              CaregiverMenuTile(
                icon: Icons.menu_book_outlined,
                title: 'دليل المرافق',
                subtitle:
                    'كيف تدعم المريض دون ضغط',
                color: CaregiverColors.gold,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const CaregiverGuideScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              CaregiverMenuTile(
                icon: Icons.self_improvement_rounded,
                title: 'رفاه المرافق',
                subtitle:
                    'اهتم بنفسك أيضًا',
                color: CaregiverColors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const CaregiverWellbeingScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              CaregiverMenuTile(
                icon: Icons.admin_panel_settings_outlined,
                title: 'الصلاحيات',
                subtitle:
                    'ما الذي يسمح لك المريض برؤيته',
                color: CaregiverColors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const FamilyPermissionsScreen(),
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

class _HomeAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _HomeAction({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CaregiverCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 31,
            color: color,
          ),
          const SizedBox(height: 9),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: CaregiverColors.brown,
            ),
          ),
        ],
      ),
    );
  }
}