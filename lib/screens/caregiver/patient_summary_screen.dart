import 'package:flutter/material.dart';

import '../../widgets/caregiver_ui.dart';

class PatientSummaryScreen extends StatelessWidget {
  const PatientSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: CaregiverPage(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const CaregiverHeader(
                title: 'ملخص سامي',
                subtitle:
                    'يظهر فقط ما سمح المريض بمشاركته.',
              ),

              const SizedBox(height: 25),

              const Row(
                children: [
                  Expanded(
                    child: _SummaryStat(
                      value: '100%',
                      label: 'جلسة اليوم',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _SummaryStat(
                      value: '5 / 7',
                      label: 'أيام الأسبوع',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _SummaryStat(
                      value: '42',
                      label: 'دقيقة تدريب',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              const CaregiverCard(
                color: Color(0xFFEAF4ED),
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      color: CaregiverColors.green,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'استمرار سامي هذا الأسبوع جيد مقارنة بأسبوعه السابق.',
                        style: TextStyle(
                          height: 1.6,
                          color: CaregiverColors.brown,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              const CaregiverCard(
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      color: CaregiverColors.blue,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الموعد القادم',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'الخميس • 10:00 صباحًا',
                            style: TextStyle(
                              color:
                                  CaregiverColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const CaregiverCard(
                color: Color(0xFFFFF2DF),
                child: Text(
                  'ملاحظات الطبيب الخاصة أو المعلومات الطبية الحساسة لا تظهر في حساب العائلة.',
                  style: TextStyle(
                    height: 1.7,
                    color: Color(0xFF7A654D),
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

class _SummaryStat extends StatelessWidget {
  final String value;
  final String label;

  const _SummaryStat({
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
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: CaregiverColors.rose,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
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