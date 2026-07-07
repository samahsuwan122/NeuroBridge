import 'package:flutter/widgets.dart';

import '../features/auth/application/auth_controller.dart';
import 'localization/locale_controller.dart';

/// Exposes the app-wide controllers (auth + locale) to the widget tree.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.auth,
    required this.locale,
    required super.child,
  });

  final AuthController auth;
  final LocaleController locale;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope was not found in the widget tree');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      auth != oldWidget.auth || locale != oldWidget.locale;
}
