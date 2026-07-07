import 'package:flutter/widgets.dart';

/// Holds the currently selected locale and notifies listeners on change.
class LocaleController extends ChangeNotifier {
  LocaleController([Locale initial = const Locale('en')]) : _locale = initial;

  Locale _locale;
  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }

  /// Toggle between English and Arabic.
  void toggle() {
    setLocale(
      _locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar'),
    );
  }
}
