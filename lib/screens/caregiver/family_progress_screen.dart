import 'package:flutter/material.dart';

import '../../widgets/caregiver_ui.dart';

class FamilyProgressScreen extends StatelessWidget {
  const FamilyProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final values = [
      .45,
      .75,
      .55,
      .85,
      .65,
      .90,
      .80,
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: CaregiverPage(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const CaregiverHeader(
                title: 'تقدّم سامي',
                subtitle:
                    'يتم مقارنة المريض بنفسه فقط.',
              ),

              const SizedBox(height: 25),

              const Row(
                children: [
                  Expanded(
                    child: _FamilyStat(
                      value: '82%',
                      label: 'الالتزام',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _FamilyStat(
                      value: '18',
                      label: 'جلسة',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _FamilyStat(
                      value: '7',
                      label: 'أيام متتالية',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              CaregiverCard(
                child: SizedBox(
                  height: 190,
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.end,
                    children: values
                        .map(
                          (value) => Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 5,
                              ),
                              child: Container(
                                height: 140 * value,
                                decoration:
                                    BoxDecoration(
                                  color:
                                      CaregiverColors
                                          .rose,
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const CaregiverCard(
                color: Color(0xFFEAF4ED),
                child: Text(
                  'تحسّن الالتزام مقارنة بالأسبوع السابق. ركّزوا على التشجيع والاستمرارية بدل النتيجة الرقمية.',
                  style: TextStyle(
                    height: 1.7,
                    color: Color(0xFF607164),
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

class _FamilyStat extends StatelessWidget {
  final String value;
  final String label;

  const _FamilyStat({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return CaregiverCard(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: CaregiverColors.rose,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: CaregiverColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}