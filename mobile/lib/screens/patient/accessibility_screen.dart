import 'package:flutter/material.dart';

import '../../core/services/accessibility_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/patient_page.dart';

class AccessibilityScreen extends StatefulWidget {
  const AccessibilityScreen({super.key});

  @override
  State<AccessibilityScreen> createState() => _AccessibilityScreenState();
}

class _AccessibilityScreenState extends State<AccessibilityScreen> {
  double textSize = 1;
  double volume = .7;

  bool highContrast = false;
  bool textToSpeech = false;
  bool reduceMotion = false;
  bool disableTimer = false;
  bool largeButtons = false;
  bool simpleMode = false;
  bool hideExtraInfo = false;
  bool loading = true;
  bool saving = false;

  static const rose = AppColors.primary;
  static const brown = AppColors.textPrimary;
  static const muted = AppColors.textSecondary;

  @override
  void initState() {
    super.initState();
    _load();
  }

  bool _bool(dynamic value) {
    return value == true || value == 1 || value?.toString() == '1';
  }

  Future<void> _load() async {
    try {
      final preferences = await AccessibilityService.load();
      if (!mounted) return;
      setState(() {
        textSize = (preferences['font_scale'] as num?)?.toDouble() ?? 1;
        volume = (preferences['volume'] as num?)?.toDouble() ?? .7;
        reduceMotion = _bool(preferences['reduce_motion']);
        highContrast = _bool(preferences['high_contrast']);
        textToSpeech = _bool(preferences['text_to_speech']);
        disableTimer = _bool(preferences['disable_timer']);
        largeButtons = _bool(preferences['large_buttons']);
        simpleMode = _bool(preferences['simple_mode']);
        hideExtraInfo = _bool(preferences['hide_extra_info']);
        loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => loading = false);
      _message(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _save() async {
    setState(() => saving = true);
    try {
      await AccessibilityService.save(
        fontScale: textSize,
        volume: volume,
        reduceMotion: reduceMotion,
        highContrast: highContrast,
        textToSpeech: textToSpeech,
        disableTimer: disableTimer,
        largeButtons: largeButtons,
        simpleMode: simpleMode,
        hideExtraInfo: hideExtraInfo,
      );
      if (!mounted) return;
      _message('تم حفظ تفضيلات سهولة الاستخدام ✓');
    } catch (error) {
      if (!mounted) return;
      _message(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
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
              if (loading) const LinearProgressIndicator(minHeight: 2),
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
                      'سهولة الاستخدام',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        color: brown,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.accessibility_new_rounded,
                    color: rose,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'خصص NeuroBridge ليكون أوضح وأسهل وأكثر راحة لك.',
                style: TextStyle(
                  height: 1.6,
                  color: muted,
                ),
              ),
              const SizedBox(height: 25),
              NeuroCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'حجم الخط',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: brown,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: textSize,
                      min: .8,
                      max: 1.5,
                      divisions: 7,
                      activeColor: rose,
                      label: '${(textSize * 100).round()}%',
                      onChanged: (value) {
                        setState(() {
                          textSize = value;
                        });
                      },
                    ),
                    Center(
                      child: Text(
                        'هذا مثال لحجم النص',
                        style: TextStyle(
                          fontSize: 16 * textSize,
                          fontWeight: FontWeight.w800,
                          color: brown,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _AccessibilitySwitch(
                icon: Icons.contrast_rounded,
                title: 'تباين أعلى',
                subtitle: 'زيادة وضوح النصوص والعناصر',
                value: highContrast,
                onChanged: (value) {
                  setState(() {
                    highContrast = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              _AccessibilitySwitch(
                icon: Icons.record_voice_over_rounded,
                title: 'قراءة النصوص بصوت',
                subtitle: 'سماع بعض النصوص والتعليمات',
                value: textToSpeech,
                onChanged: (value) {
                  setState(() {
                    textToSpeech = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              _AccessibilitySwitch(
                icon: Icons.motion_photos_off_outlined,
                title: 'تقليل الحركة',
                subtitle: 'تقليل الأنيميشن والانتقالات',
                value: reduceMotion,
                onChanged: (value) {
                  setState(() {
                    reduceMotion = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              _AccessibilitySwitch(
                icon: Icons.timer_off_outlined,
                title: 'تعطيل المؤقت',
                subtitle: 'إخفاء الوقت من التمارين التي تسمح بذلك',
                value: disableTimer,
                onChanged: (value) {
                  setState(() {
                    disableTimer = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              _AccessibilitySwitch(
                icon: Icons.touch_app_rounded,
                title: 'أزرار أكبر',
                subtitle: 'زيادة مساحة الأزرار وأهداف اللمس',
                value: largeButtons,
                onChanged: (value) {
                  setState(() {
                    largeButtons = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              _AccessibilitySwitch(
                icon: Icons.dashboard_customize_outlined,
                title: 'وضع استخدام مبسّط',
                subtitle: 'إظهار الخيارات الأساسية فقط',
                value: simpleMode,
                onChanged: (value) {
                  setState(() {
                    simpleMode = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              _AccessibilitySwitch(
                icon: Icons.visibility_off_outlined,
                title: 'إخفاء المعلومات الثانوية',
                subtitle: 'تقليل ازدحام الواجهة',
                value: hideExtraInfo,
                onChanged: (value) {
                  setState(() {
                    hideExtraInfo = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              NeuroCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.volume_up_rounded,
                          color: rose,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'مستوى الصوت',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: brown,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: volume,
                      activeColor: rose,
                      onChanged: (value) {
                        setState(() {
                          volume = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: largeButtons ? 68 : 58,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: rose,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: loading || saving ? null : _save,
                  child: saving
                      ? const SizedBox(
                          width: 23,
                          height: 23,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'حفظ الإعدادات',
                          style: TextStyle(
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
}

class _AccessibilitySwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AccessibilitySwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return NeuroCard(
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: value,
        activeThumbColor: const Color(0xFF4A3528),
        secondary: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: const Color(0xFFF1E7D8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF4A3528),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF35251C),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 11,
            height: 1.4,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
