import 'package:flutter/material.dart';

import '../../core/services/caregiver_dashboard_service.dart';
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

class CaregiverHomeScreen extends StatefulWidget {
  const CaregiverHomeScreen({
    super.key,
  });

  @override
  State<CaregiverHomeScreen> createState() {
    return _CaregiverHomeScreenState();
  }
}

class _CaregiverHomeScreenState
    extends State<CaregiverHomeScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  int? _selectedPatientId;

  Map<String, dynamic>? _caregiver;
  Map<String, dynamic>? _patient;
  Map<String, dynamic> _today = {};
  Map<String, dynamic> _summary = {};
  Map<String, dynamic>? _latestCheckin;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard({
    int? patientId,
  }) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final Map<String, dynamic> result =
          await CaregiverDashboardService.load(
        patientId:
            patientId ?? _selectedPatientId,
      );

      if (!mounted) {
        return;
      }

      final Map<String, dynamic>? patient =
          _readMap(result['patient']);

      setState(() {
        _caregiver =
            _readMap(result['caregiver']);

        _patient = patient;

        _today =
            _readMap(result['today']) ?? {};

        _summary =
            _readMap(result['summary']) ?? {};

        _latestCheckin =
            _readMap(result['latest_checkin']);

        if (patient != null) {
          _selectedPatientId =
              _readIntOrNull(patient['id']);
        }

        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  Map<String, dynamic>? _readMap(
    dynamic value,
  ) {
    if (value is Map) {
      return Map<String, dynamic>.from(
        value,
      );
    }

    return null;
  }

  int? _readIntOrNull(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    );
  }

  int _readInt(dynamic value) {
    return _readIntOrNull(value) ?? 0;
  }

  String get _caregiverFirstName {
    final String fullName =
        _caregiver?['full_name']
                ?.toString()
                .trim() ??
            '';

    if (fullName.isEmpty) {
      return 'بك';
    }

    return fullName
        .split(RegExp(r'\s+'))
        .first;
  }

  String get _patientName {
    final String name =
        _patient?['full_name']
                ?.toString()
                .trim() ??
            '';

    return name.isEmpty
        ? 'المريض'
        : name;
  }

  bool get _hasPatient {
    return _patient != null &&
        _readInt(_patient?['id']) > 0;
  }

  bool get _hasTodayActivity {
    return _today['has_activity'] == true ||
        _readInt(
              _today['completed_exercises'],
            ) >
            0;
  }

  int get _weeklyExercises {
    return _readInt(
      _summary['weekly_exercises'],
    );
  }

  int get _weeklyAverage {
    return _readInt(
      _summary['weekly_average'],
    );
  }

  int get _memoriesCount {
    return _readInt(
      _summary['memories_count'],
    );
  }

  String get _todayMessage {
    final String message =
        _today['message']
                ?.toString()
                .trim() ??
            '';

    if (message.isNotEmpty) {
      return message;
    }

    if (!_hasPatient) {
      return 'اربط مريضًا لعرض نشاطه اليومي';
    }

    return 'لا يوجد نشاط مكتمل اليوم';
  }

  String get _latestActivityText {
    final String latest =
        _summary['latest_activity']
                ?.toString()
                .trim() ??
            '';

    if (latest.isEmpty) {
      return 'لا يوجد نشاط مسجل حتى الآن';
    }

    return 'آخر نشاط: $latest';
  }

  String get _checkinText {
    if (_latestCheckin == null) {
      return 'لا يوجد تسجيل يومي حديث';
    }

    final String mood =
        _latestCheckin?['mood']
                ?.toString()
                .trim() ??
            '';

    final bool needHelp =
        _latestCheckin?['need_help'] ==
            true;

    if (needHelp) {
      if (mood.isEmpty) {
        return 'المريض يحتاج إلى مساعدة';
      }

      return 'الحالة: $mood • يحتاج إلى مساعدة';
    }

    if (mood.isEmpty) {
      return 'تم تسجيل الحالة اليومية';
    }

    return 'الحالة الأخيرة: $mood';
  }

  void _showPatientRequired() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          'يجب ربط مريض بالحساب أولًا',
        ),
      ),
    );
  }

  Future<T?> _openPage<T>(
    Widget page, {
    bool patientRequired = false,
  }) async {
    if (patientRequired && !_hasPatient) {
      _showPatientRequired();
      return null;
    }

    return Navigator.of(context).push<T>(
      MaterialPageRoute<T>(
        builder: (_) => page,
      ),
    );
  }

  Future<void> _openAndReload(
    Widget page, {
    bool patientRequired = false,
  }) async {
    await _openPage<void>(
      page,
      patientRequired: patientRequired,
    );

    if (mounted) {
      await _loadDashboard();
    }
  }

  Future<void> _choosePatient() async {
    /*
     * إذا لم يكن هناك مريض، نفتح صفحة الربط.
     */
    if (!_hasPatient) {
      await _openAndReload(
        const LinkPatientScreen(),
      );

      return;
    }

    final int? selectedPatientId =
        await Navigator.of(context).push<int>(
      MaterialPageRoute<int>(
        builder: (_) =>
            PatientSwitcherScreen(
          currentPatientId:
              _selectedPatientId,
        ),
      ),
    );

    if (
        selectedPatientId == null ||
        !mounted) {
      return;
    }

    setState(() {
      _selectedPatientId =
          selectedPatientId;
    });

    await _loadDashboard(
      patientId: selectedPatientId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 14),
            Text(
              'جارٍ تحميل بيانات العائلة...',
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 440,
            ),
            child: CaregiverCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 55,
                    color: CaregiverColors.rose,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'تعذر تحميل الصفحة',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: CaregiverColors.brown,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: CaregiverColors.muted,
                    ),
                  ),
                  const SizedBox(height: 17),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        _loadDashboard();
                      },
                      icon: const Icon(
                        Icons.refresh_rounded,
                      ),
                      label: const Text(
                        'إعادة المحاولة',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return CaregiverPage(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildPatientCard(),
          const SizedBox(height: 17),
          _buildTodayCard(),
          const SizedBox(height: 25),
          _buildQuickActions(),
          const SizedBox(height: 25),
          _buildPatientMenus(),
          const SizedBox(height: 25),
          _buildCaregiverMenus(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'أهلًا $_caregiverFirstName 🌷',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: CaregiverColors.brown,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'دعمك الهادئ يصنع فرقًا جميلًا.',
                style: TextStyle(
                  color: CaregiverColors.muted,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'تحديث',
          onPressed: () {
            _loadDashboard();
          },
          icon: const Icon(
            Icons.refresh_rounded,
            color: CaregiverColors.green,
          ),
        ),
        IconButton(
          tooltip: 'حسابي',
          onPressed: () {
            _openAndReload(
              const CaregiverProfileScreen(),
            );
          },
          icon: const Icon(
            Icons.account_circle_outlined,
            color: CaregiverColors.rose,
            size: 30,
          ),
        ),
      ],
    );
  }

  Widget _buildPatientCard() {
    return CaregiverCard(
      color: const Color(0xFFF1E7D8),
      onTap: _choosePatient,
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person_rounded,
              color: CaregiverColors.rose,
              size: 33,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _hasPatient
                      ? 'المريض الحالي'
                      : 'حساب العائلة',
                  style: const TextStyle(
                    fontSize: 11,
                    color: CaregiverColors.muted,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _hasPatient
                      ? _patientName
                      : 'لا يوجد مريض مرتبط',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: CaregiverColors.brown,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _hasPatient
                      ? (
                          _hasTodayActivity
                              ? 'نشط اليوم'
                              : 'لا يوجد نشاط اليوم')
                      : 'اضغط لربط مريض',
                  style: TextStyle(
                    color: _hasTodayActivity
                        ? CaregiverColors.green
                        : CaregiverColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            _hasPatient
                ? Icons.swap_horiz_rounded
                : Icons.link_rounded,
            color: CaregiverColors.rose,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayCard() {
    return CaregiverCard(
      child: Row(
        children: [
          Icon(
            _hasTodayActivity
                ? Icons.check_circle_rounded
                : Icons.schedule_rounded,
            color: _hasTodayActivity
                ? CaregiverColors.green
                : CaregiverColors.gold,
            size: 30,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'جلسة اليوم',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: CaregiverColors.brown,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _todayMessage,
                  style: const TextStyle(
                    fontSize: 12,
                    color: CaregiverColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
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
              enabled: _hasPatient,
              onTap: () {
                _openPage(
                  const SendEncouragementScreen(),
                  patientRequired: true,
                );
              },
            ),
            _HomeAction(
              icon:
                  Icons.add_photo_alternate_outlined,
              title: 'إضافة ذكرى',
              color: CaregiverColors.green,
              enabled: _hasPatient,
              onTap: () {
                _openAndReload(
                  const AddMemoryScreen(),
                  patientRequired: true,
                );
              },
            ),
            _HomeAction(
              icon: Icons.insights_rounded,
              title: 'التقدّم',
              color: CaregiverColors.blue,
              enabled: _hasPatient,
              onTap: () {
                _openPage(
                  const FamilyProgressScreen(),
                  patientRequired: true,
                );
              },
            ),
            _HomeAction(
              icon:
                  Icons.calendar_month_rounded,
              title: 'المواعيد',
              color: CaregiverColors.gold,
              enabled: _hasPatient,
              onTap: () {
                _openPage(
                  const FamilyAppointmentsScreen(),
                  patientRequired: true,
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPatientMenus() {
    return Column(
      children: [
        CaregiverMenuTile(
          icon: Icons.summarize_outlined,
          title: _hasPatient
              ? 'ملخص $_patientName'
              : 'ملخص المريض',
          subtitle: _hasPatient
              ? '$_weeklyExercises تمرين خلال الأسبوع'
                  ' • متوسط $_weeklyAverage%'
              : 'اربط مريضًا لعرض الملخص',
          color: CaregiverColors.rose,
          onTap: () {
            _openPage(
              const PatientSummaryScreen(),
              patientRequired: true,
            );
          },
        ),
        const SizedBox(height: 10),
        CaregiverMenuTile(
          icon: Icons.history_rounded,
          title: 'آخر النشاط',
          subtitle: _latestActivityText,
          color: CaregiverColors.blue,
          onTap: () {
            _openPage(
              const PatientActivityScreen(),
              patientRequired: true,
            );
          },
        ),
        const SizedBox(height: 10),
        CaregiverMenuTile(
          icon:
              Icons.notifications_active_outlined,
          title: 'الحالة اليومية',
          subtitle: _checkinText,
          color: CaregiverColors.gold,
          onTap: () {
            _openPage(
              const CaregiverAlertsScreen(),
              patientRequired: true,
            );
          },
        ),
        const SizedBox(height: 10),
        CaregiverMenuTile(
          icon:
              Icons.notifications_none_rounded,
          title: 'إدارة التذكيرات',
          subtitle:
              'التمارين والمواعيد والأنشطة اليومية',
          color: CaregiverColors.purple,
          onTap: () {
            _openPage(
              const ReminderManagementScreen(),
              patientRequired: true,
            );
          },
        ),
        const SizedBox(height: 10),
        CaregiverMenuTile(
          icon:
              Icons.photo_library_outlined,
          title: 'ألبوم الذكريات',
          subtitle:
              '$_memoriesCount من الذكريات العائلية',
          color: CaregiverColors.green,
          onTap: () {
            _openAndReload(
              const FamilyMemoryAlbumScreen(),
              patientRequired: true,
            );
          },
        ),
        const SizedBox(height: 10),
        CaregiverMenuTile(
          icon: Icons.link_rounded,
          title: 'ربط مريض',
          subtitle:
              'رمز المريض أو طلب ارتباط جديد',
          color: CaregiverColors.blue,
          onTap: () {
            _openAndReload(
              const LinkPatientScreen(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCaregiverMenus() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
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
          subtitle: 'كيف تدعم المريض دون ضغط',
          color: CaregiverColors.gold,
          onTap: () {
            _openPage(
              const CaregiverGuideScreen(),
            );
          },
        ),
        const SizedBox(height: 10),
        CaregiverMenuTile(
          icon:
              Icons.self_improvement_rounded,
          title: 'رفاه المرافق',
          subtitle: 'اهتم بنفسك أيضًا',
          color: CaregiverColors.green,
          onTap: () {
            _openPage(
              const CaregiverWellbeingScreen(),
            );
          },
        ),
        const SizedBox(height: 10),
        CaregiverMenuTile(
          icon:
              Icons.admin_panel_settings_outlined,
          title: 'الصلاحيات',
          subtitle:
              'ما الذي يسمح لك المريض برؤيته',
          color: CaregiverColors.purple,
          onTap: () {
            _openPage(
              const FamilyPermissionsScreen(),
              patientRequired: true,
            );
          },
        ),
      ],
    );
  }
}

class _HomeAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final bool enabled;

  const _HomeAction({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: CaregiverCard(
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
      ),
    );
  }
}