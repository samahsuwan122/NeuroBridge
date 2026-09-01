import 'package:flutter/material.dart';

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

  static const rose = AppColors.primary;
  static const brown = AppColors.textPrimary;
  static const muted = AppColors.textSecondary;

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم حفظ حالتك لليوم بشكل تجريبي 🌷',
        ),
      ),
    );

    Navigator.pop(context);
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
                      'كيف حالك اليوم؟',
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
                'هذه الأسئلة تساعدنا على تخصيص تجربتك فقط، ولا تُستخدم للتشخيص الطبي.',
                style: TextStyle(
                  height: 1.7,
                  color: muted,
                ),
              ),
              const SizedBox(height: 25),
              const PatientSectionTitle(
                title: 'كيف تشعر اليوم؟',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ('😊', 'جيد'),
                  ('🙂', 'مستقر'),
                  ('😐', 'عادي'),
                  ('😴', 'متعب'),
                ].map((item) {
                  return ChoiceChip(
                    selected: mood == item.$2,
                    selectedColor: const Color(0xFFF0E3D2),
                    label: Text(
                      '${item.$1} ${item.$2}',
                    ),
                    onSelected: (_) {
                      setState(() {
                        mood = item.$2;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 26),
              const PatientSectionTitle(
                title: 'كيف كان نومك؟',
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  'جيد',
                  'متوسط',
                  'غير مريح',
                ].map((item) {
                  return ChoiceChip(
                    selected: sleep == item,
                    selectedColor: const Color(0xFFF0E3D2),
                    label: Text(item),
                    onSelected: (_) {
                      setState(() {
                        sleep = item;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 26),
              const PatientSectionTitle(
                title: 'هل أنت مستعد للتمرين؟',
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      selected: ready == 'نعم',
                      label: const SizedBox(
                        width: double.infinity,
                        child: Text(
                          'نعم',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      selectedColor: const Color(0xFFEAF4ED),
                      onSelected: (_) {
                        setState(() {
                          ready = 'نعم';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ChoiceChip(
                      selected: ready == 'لاحقًا',
                      label: const SizedBox(
                        width: double.infinity,
                        child: Text(
                          'أفضل لاحقًا',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      selectedColor: const Color(0xFFFFF1DD),
                      onSelected: (_) {
                        setState(() {
                          ready = 'لاحقًا';
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              NeuroCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'مستوى الطاقة',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: brown,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Slider(
                      value: energy,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      activeColor: rose,
                      label: '${energy.round()} / 5',
                      onChanged: (value) {
                        setState(() {
                          energy = value;
                        });
                      },
                    ),
                    Center(
                      child: Text(
                        '${energy.round()} من 5',
                        style: const TextStyle(
                          color: muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              NeuroCard(
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: rose,
                  value: needHelp,
                  title: const Text(
                    'أحتاج مساعدة اليوم',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: brown,
                    ),
                  ),
                  subtitle: const Text(
                    'يمكننا إظهار خيارات المساعدة بشكل أوضح لك.',
                  ),
                  onChanged: (value) {
                    setState(() {
                      needHelp = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton(
                  onPressed: mood == null ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: rose,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'حفظ والمتابعة',
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
