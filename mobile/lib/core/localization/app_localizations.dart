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
      // Dashboard cards
      'todayTherapy': "Today's Therapy",
      'todayTherapyDesc': 'Your therapy activities for today.',
      'cognitiveGames': 'Cognitive Games',
      'cognitiveGamesDesc': 'Exercises for memory and attention.',
      'progress': 'Progress',
      'progressDesc': 'See how you are doing over time.',
      'reminders': 'Reminders',
      'remindersDesc': 'Medication and appointment reminders.',
      'myProfile': 'My Profile',
      'myProfileDesc': 'View your profile details.',
      'familySupport': 'Family Support',
      'familySupportDesc': 'Stay connected with your caregivers.',
      'comingSoon': 'Coming soon',
      // Patient summary
      'patientSummary': 'Patient summary',
      'noPatientProfile': 'No patient profile linked yet.',
      'profileLoadError': 'Could not load your profile. Please try again.',
      'retry': 'Retry',
      'emergencyContact': 'Emergency contact',
      'medicalCenter': 'Medical center',
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
      // Dashboard cards
      'todayTherapy': 'جلسة اليوم',
      'todayTherapyDesc': 'أنشطة العلاج الخاصة بك اليوم.',
      'cognitiveGames': 'الألعاب الإدراكية',
      'cognitiveGamesDesc': 'تمارين للذاكرة والانتباه.',
      'progress': 'التقدم',
      'progressDesc': 'تابع أداءك مع مرور الوقت.',
      'reminders': 'التذكيرات',
      'remindersDesc': 'تذكيرات الأدوية والمواعيد.',
      'myProfile': 'ملفي الشخصي',
      'myProfileDesc': 'عرض تفاصيل ملفك الشخصي.',
      'familySupport': 'دعم العائلة',
      'familySupportDesc': 'ابقَ على تواصل مع مقدّمي الرعاية.',
      'comingSoon': 'قريبًا',
      // Patient summary
      'patientSummary': 'ملخص المريض',
      'noPatientProfile': 'لا يوجد ملف مريض مرتبط بعد.',
      'profileLoadError': 'تعذّر تحميل ملفك. حاول مرة أخرى.',
      'retry': 'إعادة المحاولة',
      'emergencyContact': 'جهة اتصال للطوارئ',
      'medicalCenter': 'المركز الطبي',
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

  String get todayTherapy => _t('todayTherapy');
  String get todayTherapyDesc => _t('todayTherapyDesc');
  String get cognitiveGames => _t('cognitiveGames');
  String get cognitiveGamesDesc => _t('cognitiveGamesDesc');
  String get progress => _t('progress');
  String get progressDesc => _t('progressDesc');
  String get reminders => _t('reminders');
  String get remindersDesc => _t('remindersDesc');
  String get myProfile => _t('myProfile');
  String get myProfileDesc => _t('myProfileDesc');
  String get familySupport => _t('familySupport');
  String get familySupportDesc => _t('familySupportDesc');
  String get comingSoon => _t('comingSoon');

  String get patientSummary => _t('patientSummary');
  String get noPatientProfile => _t('noPatientProfile');
  String get profileLoadError => _t('profileLoadError');
  String get retry => _t('retry');
  String get emergencyContact => _t('emergencyContact');
  String get medicalCenter => _t('medicalCenter');
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
