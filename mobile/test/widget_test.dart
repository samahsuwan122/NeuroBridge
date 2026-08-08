import 'package:flutter_test/flutter_test.dart';
import 'package:neurobridge_mobile/main.dart';
import 'package:neurobridge_mobile/screens/splash_screen.dart';
import 'package:neurobridge_mobile/screens/welcome_screen.dart';

void main() {
  testWidgets('تظهر شاشة الترحيب', (tester) async {
    await tester.pumpWidget(const NeuroBridgeApp());

    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);
  });
}
