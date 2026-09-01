import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neurobridge_mobile/core/theme/app_theme.dart';
import 'package:neurobridge_mobile/screens/main_shell.dart';

void main() {
  const viewports = <Size>[
    Size(360, 800),
    Size(393, 852),
    Size(411, 914),
    Size(1366, 768),
  ];

  for (final viewport in viewports) {
    testWidgets(
      'patient home and navigation render at ${viewport.width.toInt()}x${viewport.height.toInt()}',
      (tester) async {
        tester.view.physicalSize = viewport;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(theme: AppTheme.light, home: const MainShell()),
        );
        await tester.pumpAndSettle();

        expect(find.text('68%'), findsOneWidget);
        expect(find.byType(GridView), findsOneWidget);
        expect(find.byType(NavigationBar), findsOneWidget);

        final visibleArea = Offset.zero & viewport;
        expect(tester.getRect(find.text('68%')).overlaps(visibleArea), isTrue);
        expect(
          tester.getRect(find.byType(NavigationBar)).overlaps(visibleArea),
          isTrue,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
