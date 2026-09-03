import 'package:flutter/material.dart';

import '../../widgets/caregiver_ui.dart';

class SendEncouragementScreen extends StatefulWidget {
  const SendEncouragementScreen({super.key});

  @override
  State<SendEncouragementScreen> createState() =>
      _SendEncouragementScreenState();
}

class _SendEncouragementScreenState extends State<SendEncouragementScreen> {
  final controller = TextEditingController();

  final templates = const [
    'نحن فخورون بك ❤️',
    'أحسنت جلسة اليوم 🌷',
    'خذ وقتك، أنت تقوم بعمل رائع.',
    'سعيدون بتقدّمك.',
  ];

  String emoji = '❤️';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _review() {
    showDialog(
      context: context,
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'مراجعة الرسالة',
            ),
            content: Text(
              '${controller.text}\n\n$emoji',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('تعديل'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'تم إرسال التشجيع تجريبيًا ❤️',
                      ),
                    ),
                  );
                },
                child: const Text('إرسال'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: CaregiverPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CaregiverHeader(
                title: 'إرسال تشجيع',
                subtitle: 'رسالة قصيرة وداعمة دون ضغط.',
              ),
              const SizedBox(height: 25),
              const Text(
                'رسائل جاهزة',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: CaregiverColors.brown,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: templates.map((message) {
                  return ActionChip(
                    label: Text(message),
                    onPressed: () {
                      controller.text = message;
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                maxLength: 180,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'رسالتك',
                  hintText: 'اكتب رسالة قصيرة...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'رمز تعبيري',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  '❤️',
                  '🌷',
                  '👏',
                  '😊',
                  '⭐',
                ].map((item) {
                  return ChoiceChip(
                    selected: emoji == item,
                    label: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    onSelected: (_) {
                      setState(() {
                        emoji = item;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.image_outlined,
                      ),
                      label: const Text(
                        'إضافة صورة',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.mic_none_rounded,
                      ),
                      label: const Text(
                        'تسجيل صوتي',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: CaregiverColors.rose,
                  ),
                  onPressed: controller.text.trim().isEmpty ? _review : _review,
                  child: const Text(
                    'مراجعة قبل الإرسال',
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
