import 'package:flutter/material.dart';

import '../../widgets/patient_page.dart';
import '../help_center_screen.dart';

import 'achievements_screen.dart';
import 'appointments_screen.dart';
import 'assistance_screen.dart';
import 'daily_check_in_screen.dart';
import 'encouragement_screen.dart';
import 'exercises_screen.dart';
import 'memory_tree_screen.dart';
import 'patient_family_screen.dart';
import 'today_plan_screen.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  static const Color rose = Color(0xFFB87585);
  static const Color roseDark = Color(0xFF95606D);
  static const Color brown = Color(0xFF4F3C38);
  static const Color muted = Color(0xFF89736F);
  static const Color border = Color(0xFFEAD8DD);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: PatientPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =====================================================
            // HEADER
            // =====================================================

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'صباح الخير، سامي 🌷',
                        style: TextStyle(
                          fontSize: 28,
                          height: 1.3,
                          fontWeight: FontWeight.w900,
                          color: brown,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'خطوة بسيطة اليوم تصنع فرقًا جميلًا.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                _HeaderButton(
                  icon: Icons.notifications_none_rounded,
                  tooltip: 'الإشعارات',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'لا توجد إشعارات جديدة حاليًا.',
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(width: 8),

                _HeaderButton(
                  icon: Icons.help_outline_rounded,
                  tooltip: 'مركز المساعدة',
                  highlighted: true,
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
              ],
            ),

            const SizedBox(height: 25),

            // =====================================================
            // TODAY SESSION
            // =====================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xFFFFE7ED),
                    Color(0xFFFFF7F9),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: const Color(0xFFE4C3CB),
                ),
                boxShadow: [
                  BoxShadow(
                    color: rose.withValues(alpha: 0.10),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(
                            alpha: 0.85,
                          ),
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: const Icon(
                          Icons.psychology_alt_rounded,
                          color: rose,
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 13),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'جلسة اليوم',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: brown,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'الذاكرة والتركيز',
                              style: TextStyle(
                                fontSize: 13,
                                color: muted,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        width: 64,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          '68%',
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: roseDark,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: const LinearProgressIndicator(
                      value: 0.68,
                      minHeight: 9,
                      backgroundColor: Color(0xFFE7CCD3),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(
                        rose,
                      ),
                    ),
                  ),

                  const SizedBox(height: 13),

                  const Row(
                    children: [
                      Icon(
                        Icons.task_alt_rounded,
                        size: 17,
                        color: roseDark,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'تمرينان متبقيان',
                          style: TextStyle(
                            fontSize: 12,
                            color: muted,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.schedule_rounded,
                        size: 17,
                        color: muted,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'حوالي 10 دقائق',
                        style: TextStyle(
                          fontSize: 12,
                          color: muted,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: rose,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const TodayPlanScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.play_arrow_rounded,
                      ),
                      label: const Text(
                        'متابعة جلسة اليوم',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // =====================================================
            // STATS
            // =====================================================

            const Row(
              children: [
                Expanded(
                  child: _MiniStatCard(
                    icon: Icons.local_fire_department_rounded,
                    value: '5',
                    label: 'أيام استمرار',
                    color: Color(0xFFC98269),
                    background: Color(0xFFFFEEE9),
                  ),
                ),

                SizedBox(width: 11),

                Expanded(
                  child: _MiniStatCard(
                    icon: Icons.task_alt_rounded,
                    value: '3 / 4',
                    label: 'تمارين اليوم',
                    color: Color(0xFF71947A),
                    background: Color(0xFFEAF4ED),
                  ),
                ),

                SizedBox(width: 11),

                Expanded(
                  child: _MiniStatCard(
                    icon: Icons.timer_outlined,
                    value: '12',
                    label: 'دقيقة اليوم',
                    color: Color(0xFF7895A4),
                    background: Color(0xFFEAF2F5),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // =====================================================
            // QUICK ACCESS
            // =====================================================

            const PatientSectionTitle(
              title: 'وصول سريع',
            ),

            const SizedBox(height: 13),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.42,
              children: [
                _QuickAction(
                  icon: Icons.psychology_alt_rounded,
                  title: 'التمارين',
                  subtitle: 'جميع التمارين',
                  color: rose,
                  background: const Color(0xFFFFE9EF),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const ExercisesScreen(),
                      ),
                    );
                  },
                ),

                _QuickAction(
                  icon: Icons.today_rounded,
                  title: 'خطة اليوم',
                  subtitle: 'مهام اليوم',
                  color: const Color(0xFF7895A4),
                  background: const Color(0xFFEAF2F5),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const TodayPlanScreen(),
                      ),
                    );
                  },
                ),

                _QuickAction(
                  icon: Icons.park_rounded,
                  title: 'شجرة الذاكرة',
                  subtitle: 'ذكرياتك الجميلة',
                  color: const Color(0xFF789981),
                  background: const Color(0xFFEAF4ED),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const MemoryTreeScreen(),
                      ),
                    );
                  },
                ),

                _QuickAction(
                  icon: Icons.favorite_outline_rounded,
                  title: 'حالتي اليوم',
                  subtitle: 'كيف تشعر؟',
                  color: const Color(0xFFC47B88),
                  background: const Color(0xFFFFEDF2),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const DailyCheckInScreen(),
                      ),
                    );
                  },
                ),

                _QuickAction(
                  icon: Icons.family_restroom_rounded,
                  title: 'العائلة',
                  subtitle: 'الأشخاص الداعمون',
                  color: const Color(0xFFC79A62),
                  background: const Color(0xFFFFF2DF),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const PatientFamilyScreen(),
                      ),
                    );
                  },
                ),

                _QuickAction(
                  icon: Icons.emoji_events_outlined,
                  title: 'الإنجازات',
                  subtitle: 'شاهد إنجازاتك',
                  color: const Color(0xFF9D7BB0),
                  background: const Color(0xFFF2EBF7),
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

            const SizedBox(height: 28),

            // =====================================================
            // FAMILY MESSAGE
            // =====================================================

            PatientSectionTitle(
              title: 'من العائلة',
              action: 'عرض الكل',
              onAction: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const EncouragementScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            NeuroCard(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const EncouragementScreen(),
                  ),
                );
              },
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xFFFFE9EF),
                    child: Text(
                      'ل',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: rose,
                      ),
                    ),
                  ),

                  SizedBox(width: 13),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'ليلى',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: brown,
                                ),
                              ),
                            ),
                            Text(
                              'منذ 10 دقائق',
                              style: TextStyle(
                                fontSize: 10,
                                color: muted,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 7),

                        Text(
                          'نحن فخورون باستمرارك اليوم يا سامي ❤️',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: Color(0xFF66514D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 27),

            // =====================================================
            // NEXT APPOINTMENT
            // =====================================================

            PatientSectionTitle(
              title: 'الموعد القادم',
              action: 'كل المواعيد',
              onAction: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AppointmentsScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            NeuroCard(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AppointmentsScreen(),
                  ),
                );
              },
              child: Row(
                children: [
                  Container(
                    width: 61,
                    height: 61,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF2F5),
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      size: 29,
                      color: Color(0xFF7895A4),
                    ),
                  ),

                  const SizedBox(width: 14),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'جلسة متابعة',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: brown,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          'د. أحمد خالد',
                          style: TextStyle(
                            fontSize: 12,
                            color: muted,
                          ),
                        ),

                        SizedBox(height: 8),

                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: Color(0xFF7895A4),
                            ),
                            SizedBox(width: 5),
                            Text(
                              'الخميس 6 أغسطس',
                              style: TextStyle(
                                fontSize: 11,
                                color: muted,
                              ),
                            ),
                            SizedBox(width: 11),
                            Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color: Color(0xFF7895A4),
                            ),
                            SizedBox(width: 5),
                            Text(
                              '10:00 ص',
                              style: TextStyle(
                                fontSize: 11,
                                color: muted,
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
                    color: Color(0xFFB5A2A6),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 27),

            // =====================================================
            // HELP
            // =====================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(19),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xFFF2EBF7),
                    Color(0xFFFFF8FA),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFE0D0E8),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: Color(0xFF9D7BB0),
                      size: 27,
                    ),
                  ),

                  const SizedBox(width: 14),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تحتاج مساعدة؟',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: brown,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'الوصول للمرافق، الدعم وتعليمات التطبيق.',
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.5,
                            color: muted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 42,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF9D7BB0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const AssistanceScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'مساعدة',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // =====================================================
            // MEDICAL NOTE
            // =====================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.58),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: border,
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.health_and_safety_outlined,
                    size: 18,
                    color: rose,
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'NeuroBridge يدعم رحلة التأهيل والمتابعة ولا يقدّم تشخيصًا طبيًا.',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.6,
                        color: muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================
// HEADER BUTTON
// =======================================================

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool highlighted;

  const _HeaderButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: highlighted
                  ? const Color(0xFFFFE9EF)
                  : Colors.white.withValues(alpha: 0.76),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: highlighted
                    ? const Color(0xFFE1BEC7)
                    : const Color(0xFFEAD8DD),
              ),
            ),
            child: Icon(
              icon,
              size: 22,
              color: highlighted
                  ? const Color(0xFFB87585)
                  : const Color(0xFF765F5B),
            ),
          ),
        ),
      ),
    );
  }
}

// =======================================================
// MINI STAT
// =======================================================

class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color background;

  const _MiniStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 118,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEAD8DD),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            value,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: Color(0xFF4F3C38),
            ),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 10,
              height: 1.3,
              color: Color(0xFF89736F),
            ),
          ),
        ],
      ),
    );
  }
}

// =======================================================
// QUICK ACTION
// =======================================================

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(21),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
              color: const Color(0xFFEAD8DD),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 49,
                height: 49,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 25,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF4F3C38),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF89736F),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 4),

              const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 13,
                color: Color(0xFFB4A1A5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}