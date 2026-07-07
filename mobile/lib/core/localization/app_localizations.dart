import 'package:flutter/widgets.dart';

/// Minimal, self-contained localization for English and Arabic.
///
/// Arabic ('ar') is a right-to-left language; Flutter applies RTL automatically
/// via GlobalWidgetsLocalizations when the active locale is Arabic.
class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [Locale('en'), Locale('ar')];

  static const Map<String, Map<String, String>> _values = {
    'en': {
      'appTitle': 'NeuroBridge',
      'loginTitle': 'Sign in',
      'emailOrPhone': 'Email or phone',
      'password': 'Password',
      'loginButton': 'Sign in',
      'logoutButton': 'Log out',
      'invalidLogin': 'Invalid email/phone or password.',
      'networkError': 'Cannot reach the server. Please try again.',
      'homeTitle': 'Home',
      'welcome': 'Welcome',
      'rolesLabel': 'Roles',
      'fieldRequired': 'This field is required.',
      'languageToggle': 'العربية',
    },
    'ar': {
      'appTitle': 'نيوروبريدج',
      'loginTitle': 'تسجيل الدخول',
      'emailOrPhone': 'البريد الإلكتروني أو الهاتف',
      'password': 'كلمة المرور',
      'loginButton': 'تسجيل الدخول',
      'logoutButton': 'تسجيل الخروج',
      'invalidLogin': 'البريد الإلكتروني/الهاتف أو كلمة المرور غير صحيحة.',
      'networkError': 'تعذّر الوصول إلى الخادم. حاول مرة أخرى.',
      'homeTitle': 'الرئيسية',
      'welcome': 'مرحبًا',
      'rolesLabel': 'الأدوار',
      'fieldRequired': 'هذا الحقل مطلوب.',
      'languageToggle': 'English',
    },
  };

  String _t(String key) =>
      _values[locale.languageCode]?[key] ?? _values['en']![key] ?? key;

  String get appTitle => _t('appTitle');
  String get loginTitle => _t('loginTitle');
  String get emailOrPhone => _t('emailOrPhone');
  String get password => _t('password');
  String get loginButton => _t('loginButton');
  String get logoutButton => _t('logoutButton');
  String get invalidLogin => _t('invalidLogin');
  String get networkError => _t('networkError');
  String get homeTitle => _t('homeTitle');
  String get welcome => _t('welcome');
  String get rolesLabel => _t('rolesLabel');
  String get fieldRequired => _t('fieldRequired');
  String get languageToggle => _t('languageToggle');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      const ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
