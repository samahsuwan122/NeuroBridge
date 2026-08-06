import 'package:flutter/material.dart';

import '../../widgets/patient_page.dart';

class AccessibilityScreen extends StatefulWidget {
  const AccessibilityScreen({super.key});

  @override
  State<AccessibilityScreen> createState() =>
      _AccessibilityScreenState();
}

class _AccessibilityScreenState
    extends State<AccessibilityScreen> {
  double textSize = 1;
  double volume = .7;

  bool highContrast = false;
  bool textToSpeech = false;
  bool reduceMotion = false;
  bool disableTimer = false;
  bool largeButtons = false;
  bool simpleMode = false;
  bool hideExtraInfo = false;

  static const rose = Color(0xFFB87585);
  static const brown = Color(0xFF4F3C38);
  static const muted = Color(0xFF89736F);

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم حفظ تفضيلات سهولة الاستخدام تجريبيًا ✓',
        ),
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
                      label:
                          '${(textSize * 100).round()}%',
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
                subtitle:
                    'زيادة وضوح النصوص والعناصر',
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
                subtitle:
                    'سماع بعض النصوص والتعليمات',
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
                subtitle:
                    'تقليل الأنيميشن والانتقالات',
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
                subtitle:
                    'إخفاء الوقت من التمارين التي تسمح بذلك',
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
                subtitle:
                    'زيادة مساحة الأزرار وأهداف اللمس',
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
                subtitle:
                    'إظهار الخيارات الأساسية فقط',
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
                subtitle:
                    'تقليل ازدحام الواجهة',
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
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: _save,
                  child: const Text(
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
        activeColor: const Color(0xFFB87585),
        secondary: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: const Color(0xFFFFE9EF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFB87585),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF4F3C38),
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