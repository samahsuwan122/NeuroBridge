import 'dart:async';

import 'package:flutter/material.dart';

import '../../widgets/patient_page.dart';

class BreakScreen extends StatefulWidget {
  final VoidCallback? onFinished;

  const BreakScreen({
    super.key,
    this.onFinished,
  });

  @override
  State<BreakScreen> createState() => _BreakScreenState();
}

class _BreakScreenState extends State<BreakScreen> {
  int seconds = 60;
  Timer? timer;
  bool natureSound = false;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (seconds <= 1) {
          timer?.cancel();

          setState(() {
            seconds = 0;
          });
        } else {
          setState(() {
            seconds--;
          });
        }
      },
    );
  }

  void _finish() {
    timer?.cancel();

    if (widget.onFinished != null) {
      widget.onFinished!();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');

    final remaining = (seconds % 60).toString().padLeft(2, '0');

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PatientPage(
          child: Column(
            children: [
              const SizedBox(height: 35),
              Container(
                width: 130,
                height: 130,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF4ED),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.spa_rounded,
                  size: 60,
                  color: Color(0xFF789981),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'وقت استراحة قصيرة 🌿',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF35251C),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'خذ نفسًا هادئًا. لا يوجد ما يدعو للاستعجال.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  height: 1.7,
                  color: Color(0xFF76665A),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                '$minutes:$remaining',
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF789981),
                ),
              ),
              const SizedBox(height: 30),
              const NeuroCard(
                color: Color(0xFFEAF4ED),
                child: Column(
                  children: [
                    Text(
                      'تمرين تنفّس بسيط',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF35251C),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'خذ شهيقًا ببطء...\n'
                      'انتظر قليلًا...\n'
                      'ثم أخرج الزفير بهدوء.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        height: 1.8,
                        color: Color(0xFF647367),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SwitchListTile(
                value: natureSound,
                activeThumbColor: const Color(0xFF789981),
                title: const Text('صوت طبيعي هادئ'),
                subtitle: const Text(
                  'اختياري',
                  style: TextStyle(fontSize: 11),
                ),
                onChanged: (value) {
                  setState(() {
                    natureSound = value;
                  });
                },
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _finish,
                  child: const Text('تخطي الاستراحة'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
