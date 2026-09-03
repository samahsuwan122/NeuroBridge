import 'package:flutter/material.dart';

import '../../widgets/caregiver_ui.dart';
import 'connection_requests_screen.dart';

class LinkPatientScreen extends StatelessWidget {
  const LinkPatientScreen({super.key});

  void _demo(
    BuildContext context,
    String text,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
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
                title: 'ربط مريض',
                subtitle:
                    'استخدم وسيلة آمنة لربط الحسابات. لا يتم الربط باستخدام الاسم فقط.',
              ),
              const SizedBox(height: 25),
              TextField(
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: 'رمز الدعوة',
                  hintText: 'NB-123456',
                  prefixIcon: const Icon(
                    Icons.key_rounded,
                    color: CaregiverColors.rose,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: CaregiverColors.rose,
                  ),
                  onPressed: () {
                    _demo(
                      context,
                      'تم إرسال طلب الربط تجريبيًا.',
                    );
                  },
                  child: const Text(
                    'إرسال طلب الربط',
                  ),
                ),
              ),
              const SizedBox(height: 25),
              CaregiverMenuTile(
                icon: Icons.qr_code_scanner_rounded,
                title: 'مسح QR Code',
                subtitle: 'امسح رمز المريض الآمن',
                color: CaregiverColors.blue,
                onTap: () {
                  _demo(
                    context,
                    'سيتم فتح الكاميرا لاحقًا.',
                  );
                },
              ),
              const SizedBox(height: 10),
              CaregiverMenuTile(
                icon: Icons.link_rounded,
                title: 'رابط مؤقت',
                subtitle: 'فتح رابط دعوة صالح لفترة محدودة',
                color: CaregiverColors.green,
                onTap: () {
                  _demo(
                    context,
                    'ميزة الرابط المؤقت ستُربط بالـBackend.',
                  );
                },
              ),
              const SizedBox(height: 10),
              CaregiverMenuTile(
                icon: Icons.how_to_reg_outlined,
                title: 'طلبات الربط',
                subtitle: 'مراجعة الطلبات والموافقات',
                color: CaregiverColors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ConnectionRequestsScreen(),
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
