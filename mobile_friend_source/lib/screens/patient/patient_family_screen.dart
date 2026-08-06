import 'package:flutter/material.dart';

import '../../widgets/patient_page.dart';
import 'encouragement_screen.dart';

class PatientFamilyScreen extends StatefulWidget {
  const PatientFamilyScreen({super.key});

  @override
  State<PatientFamilyScreen> createState() =>
      _PatientFamilyScreenState();
}

class _PatientFamilyScreenState
    extends State<PatientFamilyScreen> {
  bool allowProgress = true;

  final family = const [
    (
      'ليلى أحمد',
      'ابنة',
      'L',
      'منذ 5 دقائق'
    ),
    (
      'أحمد سامي',
      'ابن',
      'A',
      'منذ ساعتين'
    ),
    (
      'منى حسن',
      'زوجة',
      'M',
      'أمس'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PatientPage(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () =>
                        Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_forward_ios_rounded,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'العائلة',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF4F3C38),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              NeuroCard(
                color: const Color(0xFFFFE9EF),
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
                    Icon(
                      Icons.favorite_rounded,
                      color: Color(0xFFB87585),
                      size: 30,
                    ),
                    SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'آخر رسالة تشجيع',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF4F3C38),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'أحسنت جلسة اليوم، نحن فخورون بك ❤️',
                            style: TextStyle(
                              height: 1.5,
                              color: Color(0xFF89736F),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              const PatientSectionTitle(
                title: 'أفراد العائلة المرتبطون',
              ),

              const SizedBox(height: 12),

              ...family.map(
                (person) => Padding(
                  padding:
                      const EdgeInsets.only(bottom: 10),
                  child: NeuroCard(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor:
                              const Color(0xFFFFE9EF),
                          child: Text(
                            person.$3,
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.w900,
                              color: Color(
                                0xFFB87585,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                person.$1,
                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.w900,
                                  color: Color(
                                    0xFF4F3C38,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${person.$2} • ${person.$4}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(
                                    0xFF89736F,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons
                              .check_circle_outline_rounded,
                          color: Color(0xFF71947A),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              NeuroCard(
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: allowProgress,
                  activeColor:
                      const Color(0xFFB87585),
                  title: const Text(
                    'السماح للعائلة برؤية التقدّم',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4F3C38),
                    ),
                  ),
                  subtitle: const Text(
                    'يمكنك تغيير هذا الخيار في أي وقت.',
                    style: TextStyle(
                      fontSize: 11,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      allowProgress = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'تم إرسال طلب إضافة فرد بشكل تجريبي.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.person_add_alt_rounded,
                  ),
                  label: const Text(
                    'طلب إضافة فرد من العائلة',
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