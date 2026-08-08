import 'package:flutter/material.dart';

import '../../widgets/patient_page.dart';

class EncouragementScreen extends StatefulWidget {
  const EncouragementScreen({super.key});

  @override
  State<EncouragementScreen> createState() =>
      _EncouragementScreenState();
}

class _EncouragementScreenState
    extends State<EncouragementScreen> {
  final Set<int> liked = {};

  final messages = const [
    (
      'ليلى',
      'نحن فخورون بك وباستمرارك اليوم ❤️',
      'منذ 10 دقائق'
    ),
    (
      'أحمد',
      'أحسنت جلسة اليوم يا أبي 🌷',
      'منذ ساعتين'
    ),
    (
      'منى',
      'استمر بهدوء، تقدمك جميل جدًا.',
      'أمس'
    ),
    (
      'ليلى',
      'نتمنى لك يومًا سعيدًا ومريحًا.',
      'منذ يومين'
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
                      'رسائل التشجيع',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF4F3C38),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              const Text(
                'رسائل صغيرة من الأشخاص الذين يدعمونك ❤️',
                style: TextStyle(
                  color: Color(0xFF89736F),
                ),
              ),

              const SizedBox(height: 25),

              ...List.generate(
                messages.length,
                (index) {
                  final message =
                      messages[index];

                  return Padding(
                    padding:
                        const EdgeInsets.only(bottom: 13),
                    child: NeuroCard(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor:
                                    const Color(
                                  0xFFFFE9EF,
                                ),
                                child: Text(
                                  message.$1[0],
                                  style: const TextStyle(
                                    color:
                                        Color(0xFFB87585),
                                    fontWeight:
                                        FontWeight.w900,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 11),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      message.$1,
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .w900,
                                        color: Color(
                                          0xFF4F3C38,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      message.$3,
                                      style:
                                          const TextStyle(
                                        fontSize: 10,
                                        color: Color(
                                          0xFF9E8C88,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          Text(
                            message.$2,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.7,
                              color: Color(0xFF66514D),
                            ),
                          ),

                          const SizedBox(height: 14),

                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    if (liked
                                        .contains(index)) {
                                      liked.remove(index);
                                    } else {
                                      liked.add(index);
                                    }
                                  });
                                },
                                icon: Icon(
                                  liked.contains(index)
                                      ? Icons
                                          .favorite_rounded
                                      : Icons
                                          .favorite_outline_rounded,
                                  color: const Color(
                                    0xFFB87585,
                                  ),
                                  size: 19,
                                ),
                                label: Text(
                                  liked.contains(index)
                                      ? 'أرسلت قلبًا'
                                      : 'قلب',
                                  style: const TextStyle(
                                    color: Color(
                                      0xFF95606D,
                                    ),
                                  ),
                                ),
                              ),

                              TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(
                                          context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'تم إرسال "شكرًا" ❤️',
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'شكرًا',
                                ),
                              ),

                              const Spacer(),

                              IconButton(
                                tooltip:
                                    'رسالة صوتية',
                                onPressed: () {
                                  ScaffoldMessenger.of(
                                          context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'تسجيل الرسالة الصوتية سيتم ربطه لاحقًا.',
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.mic_none_rounded,
                                  color: Color(
                                    0xFFB87585,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}