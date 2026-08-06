import 'package:flutter_test/flutter_test.dart';
import 'package:neurobridge_mobile/main.dart';

void main() {
  testWidgets('تظهر شاشة الترحيب', (tester) async {
    await tester.pumpWidget(const NeuroBridgeApp());

    expect(find.text('NeuroBridge'), findsOneWidget);
    expect(find.text('إنشاء حساب جديد'), findsOneWidget);
  });
}
