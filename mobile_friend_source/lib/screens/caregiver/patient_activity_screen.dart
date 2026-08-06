import 'package:flutter/material.dart';

import '../../widgets/caregiver_ui.dart';

class PatientActivityScreen extends StatelessWidget {
  const PatientActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activities = [
      ['اليوم', '3 تمارين مكتملة', '18 دقيقة'],
      ['أمس', '2 تمرين مكتمل', '15 دقيقة'],
      ['1 أغسطس', 'جلسة مكتملة', '20 دقيقة'],
      ['31 يوليو', 'جلسة لم تكتمل', '7 دقائق'],
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: CaregiverPage(
          child: Column(
            children: [
              const CaregiverHeader(
                title: 'نشاط المريض',
                subtitle:
                    'سجل عام للنشاط دون تفاصيل طبية حساسة.',
              ),

              const SizedBox(height: 25),

              ...activities.map(
                (item) => Padding(
                  padding:
                      const EdgeInsets.only(bottom: 11),
                  child: CaregiverCard(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.history_rounded,
                          color:
                              CaregiverColors.blue,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                item[0],
                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.w900,
                                  color:
                                      CaregiverColors
                                          .brown,
                                ),
                              ),
                              Text(
                                item[1],
                                style: const TextStyle(
                                  fontSize: 11,
                                  color:
                                      CaregiverColors
                                          .muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          item[2],
                          style: const TextStyle(
                            fontSize: 11,
                            color:
                                CaregiverColors.rose,
                          ),
                        ),
                      ],
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