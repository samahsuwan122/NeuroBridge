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

class PatientHomeScreen
    extends StatelessWidget {
  const PatientHomeScreen({
    super.key,
  });

  static const Color rose =
      Color(0xFFB87585);

  static const Color roseDark =
      Color(0xFF95606D);

  static const Color brown =
      Color(0xFF4F3C38);

  static const Color muted =
      Color(0xFF89736F);

  static const Color border =
      Color(0xFFEAD8DD);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: PatientPage(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // =========================
            // HEADER
            // =========================

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        'صباح الخير، سامي 🌷',
                        style: TextStyle(
                          fontSize: 25,
                          height: 1.3,
                          fontWeight:
                              FontWeight
                                  .w900,
                          color: brown,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'خطوة بسيطة اليوم تصنع فرقًا جميلًا.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  width: 8,
                ),

                _HeaderButton(
                  icon: Icons
                      .notifications_none_rounded,
                  onTap: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'لا توجد إشعارات جديدة.',
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(
                  width: 7,
                ),

                _HeaderButton(
                  icon: Icons
                      .help_outline_rounded,
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

            const SizedBox(
              height: 24,
            ),

            // =========================
            // TODAY SESSION
            // =========================

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(
                18,
              ),
              decoration: BoxDecoration(
                gradient:
                    const LinearGradient(
                  begin:
                      Alignment.topRight,
                  end: Alignment
                      .bottomLeft,
                  colors: [
                    Color(
                      0xFFFFE5EC,
                    ),
                    Color(
                      0xFFFFF7F9,
                    ),
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(
                  25,
                ),
                border: Border.all(
                  color: const Color(
                    0xFFE5C4CD,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration:
                            BoxDecoration(
                          color:
                              Colors.white,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            16,
                          ),
                        ),
                        child:
                            const Icon(
                          Icons
                              .psychology_alt_rounded,
                          color: rose,
                          size: 27,
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              'جلسة اليوم',
                              style:
                                  TextStyle(
                                fontSize:
                                    17,
                                fontWeight:
                                    FontWeight
                                        .w900,
                                color:
                                    brown,
                              ),
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                              'الذاكرة والتركيز',
                              style:
                                  TextStyle(
                                fontSize:
                                    12,
                                color:
                                    muted,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        width: 58,
                        height: 58,
                        alignment:
                            Alignment
                                .center,
                        decoration:
                            const BoxDecoration(
                          color:
                              Colors.white,
                          shape:
                              BoxShape
                                  .circle,
                        ),
                        child:
                            const Text(
                          '68%',
                          textDirection:
                              TextDirection
                                  .ltr,
                          style:
                              TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight
                                    .w900,
                            color:
                                roseDark,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                      30,
                    ),
                    child:
                        const LinearProgressIndicator(
                      value: 0.68,
                      minHeight: 8,
                      backgroundColor:
                          Color(
                        0xFFE7CCD3,
                      ),
                      valueColor:
                          AlwaysStoppedAnimation<
                              Color>(
                        rose,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 11,
                  ),

                  const Row(
                    children: [
                      Icon(
                        Icons
                            .task_alt_rounded,
                        size: 16,
                        color:
                            roseDark,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          'تمرينان متبقيان',
                          style:
                              TextStyle(
                            fontSize:
                                11,
                            color:
                                muted,
                          ),
                        ),
                      ),
                      Icon(
                        Icons
                            .schedule_rounded,
                        size: 16,
                        color: muted,
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                        '10 دقائق',
                        style:
                            TextStyle(
                          fontSize: 11,
                          color: muted,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  SizedBox(
                    width:
                        double.infinity,
                    height: 52,
                    child:
                        FilledButton.icon(
                      style:
                          FilledButton
                              .styleFrom(
                        minimumSize:
                            const Size(
                          0,
                          52,
                        ),
                        backgroundColor:
                            rose,
                        foregroundColor:
                            Colors.white,
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            16,
                          ),
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
                        Icons
                            .play_arrow_rounded,
                      ),
                      label:
                          const Text(
                        'متابعة جلسة اليوم',
                        style:
                            TextStyle(
                          fontWeight:
                              FontWeight
                                  .w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 22,
            ),

            // =========================
            // STATS
            // =========================

            const Row(
              children: [
                Expanded(
                  child:
                      _MiniStatCard(
                    icon: Icons
                        .local_fire_department_rounded,
                    value: '5',
                    label:
                        'أيام استمرار',
                    color: Color(
                      0xFFC98269,
                    ),
                    background:
                        Color(
                      0xFFFFEEE9,
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child:
                      _MiniStatCard(
                    icon: Icons
                        .task_alt_rounded,
                    value: '3/4',
                    label:
                        'تمارين اليوم',
                    color: Color(
                      0xFF71947A,
                    ),
                    background:
                        Color(
                      0xFFEAF4ED,
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child:
                      _MiniStatCard(
                    icon: Icons
                        .timer_outlined,
                    value: '12',
                    label:
                        'دقيقة اليوم',
                    color: Color(
                      0xFF7895A4,
                    ),
                    background:
                        Color(
                      0xFFEAF2F5,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 28,
            ),

            const Text(
              'وصول سريع',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w900,
                color: brown,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            // =========================
            // QUICK ACTIONS
            // =========================

            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons
                        .psychology_alt_rounded,
                    title:
                        'التمارين',
                    subtitle:
                        'جميع التمارين',
                    color: rose,
                    background:
                        const Color(
                      0xFFFFE9EF,
                    ),
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
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: _QuickAction(
                    icon:
                        Icons.today_rounded,
                    title:
                        'خطة اليوم',
                    subtitle:
                        'مهام اليوم',
                    color:
                        const Color(
                      0xFF7895A4,
                    ),
                    background:
                        const Color(
                      0xFFEAF2F5,
                    ),
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
                ),
              ],
            ),

            const SizedBox(
              height: 10,
            ),

            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon:
                        Icons.park_rounded,
                    title:
                        'شجرة الذاكرة',
                    subtitle:
                        'ذكريات جميلة',
                    color:
                        const Color(
                      0xFF789981,
                    ),
                    background:
                        const Color(
                      0xFFEAF4ED,
                    ),
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
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: _QuickAction(
                    icon: Icons
                        .favorite_outline_rounded,
                    title:
                        'حالتي اليوم',
                    subtitle:
                        'كيف تشعر؟',
                    color:
                        const Color(
                      0xFFC47B88,
                    ),
                    background:
                        const Color(
                      0xFFFFEDF2,
                    ),
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
                ),
              ],
            ),

            const SizedBox(
              height: 10,
            ),

            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons
                        .family_restroom_rounded,
                    title:
                        'العائلة',
                    subtitle:
                        'الأشخاص الداعمون',
                    color:
                        const Color(
                      0xFFC79A62,
                    ),
                    background:
                        const Color(
                      0xFFFFF2DF,
                    ),
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
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: _QuickAction(
                    icon: Icons
                        .emoji_events_outlined,
                    title:
                        'الإنجازات',
                    subtitle:
                        'شاهد إنجازاتك',
                    color:
                        const Color(
                      0xFF9D7BB0,
                    ),
                    background:
                        const Color(
                      0xFFF2EBF7,
                    ),
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
                ),
              ],
            ),

            const SizedBox(
              height: 28,
            ),

            // =========================
            // FAMILY MESSAGE
            // =========================

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

            const SizedBox(
              height: 10,
            ),

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
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        Color(
                      0xFFFFE9EF,
                    ),
                    child: Text(
                      'ل',
                      style:
                          TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight
                                .w900,
                        color: rose,
                      ),
                    ),
                  ),

                  SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          'ليلى',
                          style:
                              TextStyle(
                            fontWeight:
                                FontWeight
                                    .w900,
                            color:
                                brown,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'نحن فخورون باستمرارك اليوم يا سامي ❤️',
                          style:
                              TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: Color(
                              0xFF66514D,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            // =========================
            // APPOINTMENT
            // =========================

            PatientSectionTitle(
              title:
                  'الموعد القادم',
              action:
                  'كل المواعيد',
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

            const SizedBox(
              height: 10,
            ),

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
              child: const Row(
                children: [
                  Icon(
                    Icons
                        .calendar_month_rounded,
                    color: Color(
                      0xFF7895A4,
                    ),
                    size: 29,
                  ),

                  SizedBox(
                    width: 13,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          'جلسة متابعة',
                          style:
                              TextStyle(
                            fontSize: 15,
                            fontWeight:
                                FontWeight
                                    .w900,
                            color:
                                brown,
                          ),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          'د. أحمد خالد',
                          style:
                              TextStyle(
                            fontSize: 11,
                            color:
                                muted,
                          ),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          'الخميس 6 أغسطس • 10:00 ص',
                          style:
                              TextStyle(
                            fontSize: 11,
                            color:
                                muted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    Icons
                        .arrow_back_ios_new_rounded,
                    size: 14,
                    color: Color(
                      0xFFB5A2A6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 26,
            ),

            // =========================
            // HELP SECTION
            // =========================

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(
                16,
              ),
              decoration: BoxDecoration(
                color: const Color(
                  0xFFF4EDF8,
                ),
                borderRadius:
                    BorderRadius.circular(
                  22,
                ),
                border: Border.all(
                  color: const Color(
                    0xFFE0D0E8,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration:
                        const BoxDecoration(
                      color:
                          Colors.white,
                      shape: BoxShape
                          .circle,
                    ),
                    child:
                        const Icon(
                      Icons
                          .support_agent_rounded,
                      color: Color(
                        0xFF9D7BB0,
                      ),
                      size: 25,
                    ),
                  ),

                  const SizedBox(
                    width: 11,
                  ),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          'تحتاج مساعدة؟',
                          style:
                              TextStyle(
                            fontSize: 15,
                            fontWeight:
                                FontWeight
                                    .w900,
                            color:
                                brown,
                          ),
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        Text(
                          'الوصول للمرافق والدعم.',
                          style:
                              TextStyle(
                            fontSize: 10,
                            color:
                                muted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  // مهم جدًا:
                  // نعطي الزر عرض ثابت.
                  SizedBox(
                    width: 85,
                    height: 43,
                    child:
                        FilledButton(
                      style:
                          FilledButton
                              .styleFrom(
                        minimumSize:
                            const Size(
                          0,
                          43,
                        ),
                        backgroundColor:
                            const Color(
                          0xFF9D7BB0,
                        ),
                        foregroundColor:
                            Colors.white,
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal:
                              8,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
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
                      child:
                          const Text(
                        'مساعدة',
                        style:
                            TextStyle(
                          fontSize: 11,
                          fontWeight:
                              FontWeight
                                  .w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            // =========================
            // DISCLAIMER
            // =========================

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(
                13,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  17,
                ),
                border: Border.all(
                  color: border,
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons
                        .health_and_safety_outlined,
                    size: 18,
                    color: rose,
                  ),

                  SizedBox(
                    width: 8,
                  ),

                  Expanded(
                    child: Text(
                      'NeuroBridge يدعم التأهيل والمتابعة ولا يقدّم تشخيصًا طبيًا.',
                      style:
                          TextStyle(
                        fontSize: 10,
                        height: 1.5,
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

// =========================================
// HEADER BUTTON
// =========================================

class _HeaderButton
    extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool highlighted;

  const _HeaderButton({
    required this.icon,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: highlighted
                ? const Color(
                    0xFFFFE9EF,
                  )
                : Colors.white,
            borderRadius:
                BorderRadius.circular(
              14,
            ),
            border: Border.all(
              color: highlighted
                  ? const Color(
                      0xFFE1BEC7,
                    )
                  : const Color(
                      0xFFEAD8DD,
                    ),
            ),
          ),
          child: Icon(
            icon,
            size: 21,
           color: highlighted
    ? PatientHomeScreen.rose
    : const Color(
        0xFF765F5B,
      ),
          ),
        ),
      ),
    );
  }
}

// =========================================
// MINI STAT
// =========================================

class _MiniStatCard
    extends StatelessWidget {
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
      height: 105,
      padding:
          const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(
            0xFFEAD8DD,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Container(
            width: 33,
            height: 33,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            value,
            textDirection:
                TextDirection.ltr,
            style: const TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.w900,
              color: Color(
                0xFF4F3C38,
              ),
            ),
          ),

          Text(
            label,
            maxLines: 2,
            textAlign:
                TextAlign.center,
            style: const TextStyle(
              fontSize: 9,
              height: 1.2,
              color: Color(
                0xFF89736F,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================
// QUICK ACTION
// =========================================

class _QuickAction
    extends StatelessWidget {
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
        borderRadius:
            BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          height: 90,
          padding:
              const EdgeInsets.all(
            11,
          ),
          decoration:
              BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(
              20,
            ),
            border: Border.all(
              color: const Color(
                0xFFEAD8DD,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration:
                    BoxDecoration(
                  color: background,
                  borderRadius:
                      BorderRadius
                          .circular(
                    14,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: color,
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          const TextStyle(
                        fontSize: 12,
                        fontWeight:
                            FontWeight
                                .w900,
                        color: Color(
                          0xFF4F3C38,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          const TextStyle(
                        fontSize: 9,
                        color: Color(
                          0xFF89736F,
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