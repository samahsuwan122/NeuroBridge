import 'package:flutter/material.dart';

import '../../widgets/caregiver_ui.dart';

class PatientSwitcherScreen extends StatefulWidget {
  const PatientSwitcherScreen({super.key});

  @override
  State<PatientSwitcherScreen> createState() => _PatientSwitcherScreenState();
}

class _PatientSwitcherScreenState extends State<PatientSwitcherScreen> {
  int selected = 0;

  final patients = const [
    ['سامي أحمد', 'نشط اليوم', 'S'],
    ['منى أحمد', 'آخر نشاط: أمس', 'M'],
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: CaregiverPage(
          child: Column(
            children: [
              const CaregiverHeader(
                title: 'اختيار المريض',
                subtitle: 'يمكنك التنقل بين الأشخاص المرتبطين بحسابك.',
              ),
              const SizedBox(height: 25),
              ...List.generate(
                patients.length,
                (index) {
                  final active = selected == index;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CaregiverCard(
                      color: active ? const Color(0xFFF1E7D8) : null,
                      onTap: () {
                        setState(() {
                          selected = index;
                        });
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white,
                            child: Text(
                              patients[index][2],
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: CaregiverColors.rose,
                              ),
                            ),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  patients[index][0],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: CaregiverColors.brown,
                                  ),
                                ),
                                Text(
                                  patients[index][1],
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: CaregiverColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            active
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: active
                                ? CaregiverColors.rose
                                : CaregiverColors.muted,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: CaregiverColors.rose,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'استخدام هذا الملف',
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
