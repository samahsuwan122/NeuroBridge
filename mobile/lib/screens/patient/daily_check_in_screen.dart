import 'package:flutter/material.dart';

import '../../core/services/patient_features_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/patient_page.dart';

class DailyCheckInScreen extends StatefulWidget {
  const DailyCheckInScreen({super.key});

  @override
  State<DailyCheckInScreen> createState() => _DailyCheckInScreenState();
}

class _DailyCheckInScreenState extends State<DailyCheckInScreen> {
  String? mood;
  String? sleep;
  String? ready;

  double energy = 3;
  bool needHelp = false;
  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  bool _bool(dynamic value) {
    return value == true ||
        value == 1 ||
        value?.toString() == '1' ||
        value?.toString().toLowerCase() == 'true';
  }

  Future<void> _load() async {
    try {
      final data = await PatientFeaturesService.loadCheckin();

      if (!mounted) return;

      setState(() {
        mood = data?['mood']?.toString();
        sleep = data?['sleep_quality']?.toString();
        ready = data?['readiness']?.toString();

        energy = double.tryParse(
              data?['energy']?.toString() ?? '',
            ) ??
            3;

        energy = energy.clamp(1, 5);
        needHelp = _bool(data?['need_help']);
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذّر تحميل حالة اليوم'),
        ),
      );
    }
  }

  Future<void> _save() async {
    if (mood == null || sleep == null || ready == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى الإجابة عن جميع الأسئلة أولًا'),
        ),
      );
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      await PatientFeaturesService.saveCheckin({
        'mood': mood,
        'sleep_quality': sleep,
        'readiness': ready,
        'energy': energy.round(),
        'need_help': needHelp,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ حالتك لليوم 🌷'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _choiceButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    String? emoji,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.055),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.20),
            width: selected ? 1.8 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.20),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(
                emoji,
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 18,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _readyButton({
    required String title,
    required String value,
    required IconData icon,
  }) {
    final selected = ready == value;

    return InkWell(
      onTap: () {
        setState(() {
          ready = value;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.055),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 9),
            Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _energyText {
    switch (energy.round()) {
      case 1:
        return 'منخفضة جدًا';
      case 2:
        return 'منخفضة';
      case 3:
        return 'متوسطة';
      case 4:
        return 'جيدة';
      case 5:
        return 'ممتازة';
      default:
        return 'متوسطة';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PatientPage(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 650;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 4 : 24,
                  vertical: 18,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 850,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (loading)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: const LinearProgressIndicator(
                              minHeight: 4,
                              color: AppColors.primary,
                            ),
                          ),

                        if (loading) const SizedBox(height: 14),

                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: IconButton(
                                tooltip: 'رجوع',
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Text(
                                'كيف حالك اليوم؟',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(17),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lock_outline_rounded,
                                color: AppColors.primary,
                                size: 21,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'تساعدنا إجاباتك على تخصيص تجربتك، '
                                  'ولا تُستخدم للتشخيص الطبي.',
                                  style: TextStyle(
                                    height: 1.6,
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        _sectionCard(
                          title: 'كيف تشعر اليوم؟',
                          icon: Icons.sentiment_satisfied_alt_rounded,
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _choiceButton(
                                emoji: '😊',
                                label: 'جيد',
                                selected: mood == 'جيد',
                                onTap: () => setState(() => mood = 'جيد'),
                              ),
                              _choiceButton(
                                emoji: '🙂',
                                label: 'مستقر',
                                selected: mood == 'مستقر',
                                onTap: () => setState(() => mood = 'مستقر'),
                              ),
                              _choiceButton(
                                emoji: '😐',
                                label: 'عادي',
                                selected: mood == 'عادي',
                                onTap: () => setState(() => mood = 'عادي'),
                              ),
                              _choiceButton(
                                emoji: '😴',
                                label: 'متعب',
                                selected: mood == 'متعب',
                                onTap: () => setState(() => mood = 'متعب'),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        _sectionCard(
                          title: 'كيف كان نومك؟',
                          icon: Icons.bedtime_outlined,
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _choiceButton(
                                label: 'جيد',
                                selected: sleep == 'جيد',
                                onTap: () => setState(() => sleep = 'جيد'),
                              ),
                              _choiceButton(
                                label: 'متوسط',
                                selected: sleep == 'متوسط',
                                onTap: () => setState(() => sleep = 'متوسط'),
                              ),
                              _choiceButton(
                                label: 'غير مريح',
                                selected: sleep == 'غير مريح',
                                onTap: () {
                                  setState(() => sleep = 'غير مريح');
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        _sectionCard(
                          title: 'هل أنت مستعد للتمرين؟',
                          icon: Icons.fitness_center_rounded,
                          child: isMobile
                              ? Column(
                                  children: [
                                    _readyButton(
                                      title: 'نعم، أنا مستعد',
                                      value: 'نعم',
                                      icon: Icons.check_circle_outline_rounded,
                                    ),
                                    const SizedBox(height: 10),
                                    _readyButton(
                                      title: 'أفضل لاحقًا',
                                      value: 'لاحقًا',
                                      icon: Icons.schedule_rounded,
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: _readyButton(
                                        title: 'نعم، أنا مستعد',
                                        value: 'نعم',
                                        icon:
                                            Icons.check_circle_outline_rounded,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _readyButton(
                                        title: 'أفضل لاحقًا',
                                        value: 'لاحقًا',
                                        icon: Icons.schedule_rounded,
                                      ),
                                    ),
                                  ],
                                ),
                        ),

                        const SizedBox(height: 16),

                        _sectionCard(
                          title: 'مستوى الطاقة',
                          icon: Icons.bolt_rounded,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _energyText,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 13,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${energy.round()} من 5',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Slider(
                                value: energy,
                                min: 1,
                                max: 5,
                                divisions: 4,
                                activeColor: AppColors.primary,
                                inactiveColor:
                                    AppColors.primary.withValues(alpha: 0.17),
                                label: '${energy.round()} من 5',
                                onChanged: (value) {
                                  setState(() {
                                    energy = value;
                                  });
                                },
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'منخفضة',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      'مرتفعة',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: needHelp
                                ? Colors.orange.withValues(alpha: 0.09)
                                : Colors.white.withValues(alpha: 0.82),
                            borderRadius: BorderRadius.circular(19),
                            border: Border.all(
                              color: needHelp
                                  ? Colors.orange.withValues(alpha: 0.45)
                                  : AppColors.primary.withValues(alpha: 0.14),
                            ),
                          ),
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            value: needHelp,
                            activeColor: AppColors.primary,
                            title: const Text(
                              'أحتاج مساعدة اليوم',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            subtitle: const Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: Text(
                                'فعّل هذا الخيار إذا كنت ترغب بالحصول على المساعدة.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            secondary: Icon(
                              Icons.volunteer_activism_outlined,
                              color: needHelp
                                  ? Colors.orange
                                  : AppColors.primary,
                              size: 28,
                            ),
                            onChanged: (value) {
                              setState(() {
                                needHelp = value;
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: FilledButton.icon(
                            onPressed: loading || saving ? null : _save,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor:
                                  AppColors.primary.withValues(alpha: 0.35),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(17),
                              ),
                            ),
                            icon: saving
                                ? const SizedBox(
                                    width: 23,
                                    height: 23,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.white,
                                  ),
                            label: Text(
                              saving ? 'جارٍ الحفظ...' : 'حفظ والمتابعة',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}