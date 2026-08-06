import 'package:flutter/material.dart';

import '../../widgets/patient_page.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() =>
      _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState
    extends State<ActivityHistoryScreen> {
  String filter = 'الأسبوع';

  final sessions = const [
    (
      'اليوم',
      'تذكّر الكلمات • مطابقة البطاقات',
      '18 دقيقة',
      'مكتملة',
      '82%'
    ),
    (
      'أمس',
      'ترتيب الأحداث • التسلسل',
      '15 دقيقة',
      'مكتملة',
      '76%'
    ),
    (
      '1 أغسطس',
      'الاستماع • الإدراك البصري',
      '20 دقيقة',
      'مكتملة',
      '80%'
    ),
    (
      '31 يوليو',
      'تذكّر الكلمات',
      '8 دقائق',
      'مكتملة جزئيًا',
      '—'
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_forward_ios_rounded,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'سجل النشاط',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF4F3C38),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Wrap(
                spacing: 8,
                children: [
                  'اليوم',
                  'الأسبوع',
                  'الشهر',
                ].map((item) {
                  return ChoiceChip(
                    label: Text(item),
                    selected: filter == item,
                    selectedColor:
                        const Color(0xFFFFE1E9),
                    onSelected: (_) {
                      setState(() {
                        filter = item;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 25),

              ...sessions.map(
                (session) => Padding(
                  padding:
                      const EdgeInsets.only(bottom: 12),
                  child: NeuroCard(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 47,
                              height: 47,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFFFE9EF,
                                ),
                                borderRadius:
                                    BorderRadius.circular(
                                  15,
                                ),
                              ),
                              child: const Icon(
                                Icons
                                    .psychology_alt_rounded,
                                color:
                                    Color(0xFFB87585),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    session.$1,
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.w900,
                                      color: Color(
                                        0xFF4F3C38,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    session.$2,
                                    style:
                                        const TextStyle(
                                      fontSize: 11,
                                      color: Color(
                                        0xFF89736F,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              session.$5,
                              style: const TextStyle(
                                color:
                                    Color(0xFF95606D),
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 13),

                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 16,
                              color: Color(0xFF89736F),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              session.$3,
                              style: const TextStyle(
                                fontSize: 11,
                                color:
                                    Color(0xFF89736F),
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.task_alt_rounded,
                              size: 16,
                              color: Color(0xFF71947A),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              session.$4,
                              style: const TextStyle(
                                fontSize: 11,
                                color:
                                    Color(0xFF71947A),
                              ),
                            ),
                          ],
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