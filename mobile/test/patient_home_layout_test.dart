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

  const testUser = <String, dynamic>{
    'id': 1,
    'full_name': 'تالا',
    'email': 'test@example.com',
    'phone': '0590000000',
    'role': 'patient',
    'is_verified': true,
  };

  for (final viewport in viewports) {
    testWidgets(
      'patient home and navigation render at '
      '${viewport.width.toInt()}x${viewport.height.toInt()}',
      (tester) async {
        tester.view.physicalSize = viewport;
        tester.view.devicePixelRatio = 1;

        addTearDown(
          tester.view.resetPhysicalSize,
        );

        addTearDown(
          tester.view.resetDevicePixelRatio,
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: const MainShell(
              user: testUser,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // الاسم أصبح ديناميكيًا حسب بيانات المستخدم.
        expect(
          find.text('صباح الخير، تالا 🌷'),
          findsOneWidget,
        );

        expect(
          find.text('68%'),
          findsOneWidget,
        );

        expect(
          find.byType(GridView),
          findsOneWidget,
        );

        expect(
          find.byType(NavigationBar),
          findsOneWidget,
        );

        final visibleArea = Offset.zero & viewport;

        expect(
          tester
              .getRect(
                find.text('68%'),
              )
              .overlaps(visibleArea),
          isTrue,
        );

        expect(
          tester
              .getRect(
                find.byType(NavigationBar),
              )
              .overlaps(visibleArea),
          isTrue,
        );

        expect(
          tester.takeException(),
          isNull,
        );
      },
    );
  }
}