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
      'loginSubtitle': 'Bridging memory. Connecting lives.',
      'homeSupportiveMessage': 'Small steps every day make a difference.',
      'basicInformation': 'Basic Information',
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
      'memoryAlbumDesc': 'Photos and stories from your life.',
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
      // Games
      'gamesTitle': 'Cognitive Games',
      'loadingGames': 'Loading games…',
      'noGamesAvailable': 'No games available yet.',
      'gamesLoadError': 'Could not load games. Please try again.',
      'difficulty': 'Difficulty',
      'estimatedDuration': 'Estimated duration',
      'minutes': 'min',
      'instructions': 'Instructions',
      'gameDetails': 'Game details',
      'gamePlayComingLater': 'Game play will be added in a later phase.',
      'play': 'Play',
      'moves': 'Moves',
      'matches': 'Matches',
      'mistakes': 'Mistakes',
      'time': 'Time',
      'wellDone': 'Well done!',
      'playAgain': 'Play again',
      'gameSummary': 'Game summary',
      'performanceOnlyNote':
          'This is a cognitive exercise. Scores reflect game performance only.',
      'savingResult': 'Saving result…',
      'resultSaved': 'Result saved',
      'resultSaveFailed': 'Could not save result.',
      'retrySave': 'Retry',
      // Progress
      'progressSubtitle': 'Your recent exercise performance.',
      'loadingProgress': 'Loading your progress…',
      'noProgressYet': 'No results yet. Play a game to see your progress here.',
      'progressLoadFailed': 'Could not load your progress. Please try again.',
      'score': 'Score',
      'duration': 'Duration',
      'completed': 'Completed',
      'notCompleted': 'Not completed',
      'date': 'Date',
      'performanceOnlyProgressNote':
          'These are cognitive exercise results (game performance only), not a medical assessment.',
      // Profile
      'profileSubtitle': 'Your basic profile information.',
      'loadingProfile': 'Loading your profile…',
      'profileLoadFailed': 'Could not load your profile. Please try again.',
      'fullName': 'Full name',
      'email': 'Email',
      'phone': 'Phone',
      'dateOfBirth': 'Date of birth',
      'gender': 'Gender',
      'memberSince': 'Member since',
      'notProvided': 'Not provided',
      // Care & safety
      'careSafetyInformation': 'Care & Safety Information',
      'careSafetyNote':
          'These are care and safety details only, not a medical diagnosis.',
      'allergies': 'Allergies',
      'currentMedications': 'Current medications',
      'bloodType': 'Blood type',
      'mobilityNeeds': 'Mobility needs',
      'visionHearingNeeds': 'Vision/hearing needs',
      'preferredCommunication': 'Preferred communication',
      'caregiverNotes': 'Caregiver notes',
      // Memory Album
      'memoryAlbum': 'Memory Album',
      'memoryAlbumSubtitle': 'Cherished memories with your family.',
      'memoryAlbumNote':
          'Memories are for family connection and supportive recall activities only.',
      'loadingMemories': 'Loading memories…',
      'noMemoriesYet': 'No memories yet.',
      'memoriesLoadFailed': 'Could not load memories. Please try again.',
      'memoryDetails': 'Memory details',
      'personName': 'Person',
      'relationship': 'Relationship',
      'place': 'Place',
      'memoryDate': 'Memory date',
      'category': 'Category',
      'mediaType': 'Media type',
      'mediaUrl': 'Media',
      'createdAt': 'Added on',
      'viewDetails': 'View details',
      // Add Memory form
      'addMemory': 'Add memory',
      'saveMemory': 'Save memory',
      'memoryTitle': 'Title',
      'memoryDescription': 'Description',
      'memoryTitleRequired': 'Please enter a title.',
      'memorySaved': 'Memory saved.',
      'memorySaveFailed': 'Could not save the memory. Please try again.',
      'optional': 'Optional',
      'cancel': 'Cancel',
      'submitting': 'Saving…',
      'memoryDateHint': 'YYYY-MM-DD',
      'mediaUrlHint': 'Link or note (optional)',
      // Image upload
      'chooseImage': 'Choose image',
      'changeImage': 'Change image',
      'imageSelected': 'Selected image',
      'imageRequirements': 'JPEG, PNG, or WebP up to 5 MB.',
      'imageUploadFailed': 'Could not upload the image. Please try again.',
      'imageUploadSuccess': 'Memory and image saved.',
      'unsupportedImageType': 'Unsupported image type. Use JPEG, PNG, or WebP.',
      'imageTooLarge': 'The image is too large (maximum 5 MB).',
      'memoryCreatedImageFailed':
          'Memory saved, but the image could not be uploaded. You can add it later.',
      'imageAttached': 'Image attached',
      'imagePreview': 'Image preview',
      'imageUnavailable': 'Image unavailable',
      'memoryImage': 'Memory image',
      'noImageAttached': 'No image attached',
    },
    'ar': {
      'appTitle': 'نيوروبريدج',
      'loginSubtitle': 'نجسر الذاكرة، ونصل الحياة.',
      'homeSupportiveMessage': 'خطوات صغيرة كل يوم تُحدث فرقًا.',
      'basicInformation': 'المعلومات الأساسية',
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
      'memoryAlbumDesc': 'صور وقصص من حياتك.',
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
      // Games
      'gamesTitle': 'الألعاب الإدراكية',
      'loadingGames': 'جارٍ تحميل الألعاب…',
      'noGamesAvailable': 'لا توجد ألعاب متاحة بعد.',
      'gamesLoadError': 'تعذّر تحميل الألعاب. حاول مرة أخرى.',
      'difficulty': 'الصعوبة',
      'estimatedDuration': 'المدة التقديرية',
      'minutes': 'دقيقة',
      'instructions': 'التعليمات',
      'gameDetails': 'تفاصيل اللعبة',
      'gamePlayComingLater': 'سيتم إضافة اللعب في مرحلة لاحقة.',
      'play': 'العب',
      'moves': 'الحركات',
      'matches': 'المطابقات',
      'mistakes': 'الأخطاء',
      'time': 'الوقت',
      'wellDone': 'أحسنت!',
      'playAgain': 'العب مرة أخرى',
      'gameSummary': 'ملخص اللعبة',
      'performanceOnlyNote': 'هذا تمرين إدراكي. النتائج تعكس أداء اللعبة فقط.',
      'savingResult': 'جارٍ حفظ النتيجة…',
      'resultSaved': 'تم حفظ النتيجة',
      'resultSaveFailed': 'تعذّر حفظ النتيجة.',
      'retrySave': 'إعادة المحاولة',
      // Progress
      'progressSubtitle': 'أداؤك الأخير في التمارين.',
      'loadingProgress': 'جارٍ تحميل تقدمك…',
      'noProgressYet': 'لا توجد نتائج بعد. العب لعبة لرؤية تقدمك هنا.',
      'progressLoadFailed': 'تعذّر تحميل تقدمك. حاول مرة أخرى.',
      'score': 'النتيجة',
      'duration': 'المدة',
      'completed': 'مكتمل',
      'notCompleted': 'غير مكتمل',
      'date': 'التاريخ',
      'performanceOnlyProgressNote':
          'هذه نتائج تمارين إدراكية (أداء اللعبة فقط)، وليست تقييمًا طبيًا.',
      // Profile
      'profileSubtitle': 'معلومات ملفك الأساسية.',
      'loadingProfile': 'جارٍ تحميل ملفك…',
      'profileLoadFailed': 'تعذّر تحميل ملفك. حاول مرة أخرى.',
      'fullName': 'الاسم الكامل',
      'email': 'البريد الإلكتروني',
      'phone': 'الهاتف',
      'dateOfBirth': 'تاريخ الميلاد',
      'gender': 'الجنس',
      'memberSince': 'عضو منذ',
      'notProvided': 'غير متوفر',
      // Care & safety
      'careSafetyInformation': 'معلومات الرعاية والسلامة',
      'careSafetyNote': 'هذه تفاصيل رعاية وسلامة فقط، وليست تشخيصًا طبيًا.',
      'allergies': 'الحساسية',
      'currentMedications': 'الأدوية الحالية',
      'bloodType': 'فصيلة الدم',
      'mobilityNeeds': 'احتياجات الحركة',
      'visionHearingNeeds': 'احتياجات البصر/السمع',
      'preferredCommunication': 'طريقة التواصل المفضّلة',
      'caregiverNotes': 'ملاحظات مقدّم الرعاية',
      // Memory Album
      'memoryAlbum': 'ألبوم الذكريات',
      'memoryAlbumSubtitle': 'ذكريات عزيزة مع عائلتك.',
      'memoryAlbumNote':
          'الذكريات مخصّصة للتواصل العائلي وأنشطة الاستذكار الداعمة فقط.',
      'loadingMemories': 'جارٍ تحميل الذكريات…',
      'noMemoriesYet': 'لا توجد ذكريات بعد.',
      'memoriesLoadFailed': 'تعذّر تحميل الذكريات. حاول مرة أخرى.',
      'memoryDetails': 'تفاصيل الذكرى',
      'personName': 'الشخص',
      'relationship': 'صلة القرابة',
      'place': 'المكان',
      'memoryDate': 'تاريخ الذكرى',
      'category': 'الفئة',
      'mediaType': 'نوع الوسائط',
      'mediaUrl': 'الوسائط',
      'createdAt': 'أُضيفت في',
      'viewDetails': 'عرض التفاصيل',
      // Add Memory form
      'addMemory': 'إضافة ذكرى',
      'saveMemory': 'حفظ الذكرى',
      'memoryTitle': 'العنوان',
      'memoryDescription': 'الوصف',
      'memoryTitleRequired': 'يرجى إدخال عنوان.',
      'memorySaved': 'تم حفظ الذكرى.',
      'memorySaveFailed': 'تعذّر حفظ الذكرى. حاول مرة أخرى.',
      'optional': 'اختياري',
      'cancel': 'إلغاء',
      'submitting': 'جارٍ الحفظ…',
      'memoryDateHint': 'YYYY-MM-DD',
      'mediaUrlHint': 'رابط أو ملاحظة (اختياري)',
      // Image upload
      'chooseImage': 'اختيار صورة',
      'changeImage': 'تغيير الصورة',
      'imageSelected': 'الصورة المحددة',
      'imageRequirements': 'JPEG أو PNG أو WebP حتى ٥ ميجابايت.',
      'imageUploadFailed': 'تعذّر رفع الصورة. حاول مرة أخرى.',
      'imageUploadSuccess': 'تم حفظ الذكرى والصورة.',
      'unsupportedImageType': 'نوع صورة غير مدعوم. استخدم JPEG أو PNG أو WebP.',
      'imageTooLarge': 'الصورة كبيرة جدًا (الحد الأقصى ٥ ميجابايت).',
      'memoryCreatedImageFailed':
          'تم حفظ الذكرى، لكن تعذّر رفع الصورة. يمكنك إضافتها لاحقًا.',
      'imageAttached': 'صورة مرفقة',
      'imagePreview': 'معاينة الصورة',
      'imageUnavailable': 'الصورة غير متاحة',
      'memoryImage': 'صورة الذكرى',
      'noImageAttached': 'لا توجد صورة مرفقة',
    },
  };

  String _t(String key) =>
      _values[locale.languageCode]?[key] ?? _values['en']![key] ?? key;

  String get appTitle => _t('appTitle');
  String get loginSubtitle => _t('loginSubtitle');
  String get homeSupportiveMessage => _t('homeSupportiveMessage');
  String get basicInformation => _t('basicInformation');
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
  String get memoryAlbumDesc => _t('memoryAlbumDesc');
  String get familySupport => _t('familySupport');
  String get familySupportDesc => _t('familySupportDesc');
  String get comingSoon => _t('comingSoon');

  String get patientSummary => _t('patientSummary');
  String get noPatientProfile => _t('noPatientProfile');
  String get profileLoadError => _t('profileLoadError');
  String get retry => _t('retry');
  String get emergencyContact => _t('emergencyContact');
  String get medicalCenter => _t('medicalCenter');

  String get gamesTitle => _t('gamesTitle');
  String get loadingGames => _t('loadingGames');
  String get noGamesAvailable => _t('noGamesAvailable');
  String get gamesLoadError => _t('gamesLoadError');
  String get difficulty => _t('difficulty');
  String get estimatedDuration => _t('estimatedDuration');
  String get minutes => _t('minutes');
  String get instructions => _t('instructions');
  String get gameDetails => _t('gameDetails');
  String get gamePlayComingLater => _t('gamePlayComingLater');
  String get play => _t('play');
  String get moves => _t('moves');
  String get matches => _t('matches');
  String get mistakes => _t('mistakes');
  String get time => _t('time');
  String get wellDone => _t('wellDone');
  String get playAgain => _t('playAgain');
  String get gameSummary => _t('gameSummary');
  String get performanceOnlyNote => _t('performanceOnlyNote');
  String get savingResult => _t('savingResult');
  String get resultSaved => _t('resultSaved');
  String get resultSaveFailed => _t('resultSaveFailed');
  String get retrySave => _t('retrySave');

  String get progressSubtitle => _t('progressSubtitle');
  String get loadingProgress => _t('loadingProgress');
  String get noProgressYet => _t('noProgressYet');
  String get progressLoadFailed => _t('progressLoadFailed');
  String get score => _t('score');
  String get duration => _t('duration');
  String get completed => _t('completed');
  String get notCompleted => _t('notCompleted');
  String get date => _t('date');
  String get performanceOnlyProgressNote => _t('performanceOnlyProgressNote');

  String get profileSubtitle => _t('profileSubtitle');
  String get loadingProfile => _t('loadingProfile');
  String get profileLoadFailed => _t('profileLoadFailed');
  String get fullName => _t('fullName');
  String get email => _t('email');
  String get phone => _t('phone');
  String get dateOfBirth => _t('dateOfBirth');
  String get gender => _t('gender');
  String get memberSince => _t('memberSince');
  String get notProvided => _t('notProvided');

  String get careSafetyInformation => _t('careSafetyInformation');
  String get careSafetyNote => _t('careSafetyNote');
  String get allergies => _t('allergies');
  String get currentMedications => _t('currentMedications');
  String get bloodType => _t('bloodType');
  String get mobilityNeeds => _t('mobilityNeeds');
  String get visionHearingNeeds => _t('visionHearingNeeds');
  String get preferredCommunication => _t('preferredCommunication');
  String get caregiverNotes => _t('caregiverNotes');

  String get memoryAlbum => _t('memoryAlbum');
  String get memoryAlbumSubtitle => _t('memoryAlbumSubtitle');
  String get memoryAlbumNote => _t('memoryAlbumNote');
  String get loadingMemories => _t('loadingMemories');
  String get noMemoriesYet => _t('noMemoriesYet');
  String get memoriesLoadFailed => _t('memoriesLoadFailed');
  String get memoryDetails => _t('memoryDetails');
  String get personName => _t('personName');
  String get relationship => _t('relationship');
  String get place => _t('place');
  String get memoryDate => _t('memoryDate');
  String get category => _t('category');
  String get mediaType => _t('mediaType');
  String get mediaUrl => _t('mediaUrl');
  String get createdAt => _t('createdAt');
  String get viewDetails => _t('viewDetails');

  String get addMemory => _t('addMemory');
  String get saveMemory => _t('saveMemory');
  String get memoryTitle => _t('memoryTitle');
  String get memoryDescription => _t('memoryDescription');
  String get memoryTitleRequired => _t('memoryTitleRequired');
  String get memorySaved => _t('memorySaved');
  String get memorySaveFailed => _t('memorySaveFailed');
  String get optional => _t('optional');
  String get cancel => _t('cancel');
  String get submitting => _t('submitting');
  String get memoryDateHint => _t('memoryDateHint');
  String get mediaUrlHint => _t('mediaUrlHint');

  String get chooseImage => _t('chooseImage');
  String get changeImage => _t('changeImage');
  String get imageSelected => _t('imageSelected');
  String get imageRequirements => _t('imageRequirements');
  String get imageUploadFailed => _t('imageUploadFailed');
  String get imageUploadSuccess => _t('imageUploadSuccess');
  String get unsupportedImageType => _t('unsupportedImageType');
  String get imageTooLarge => _t('imageTooLarge');
  String get memoryCreatedImageFailed => _t('memoryCreatedImageFailed');
  String get imageAttached => _t('imageAttached');
  String get imagePreview => _t('imagePreview');
  String get imageUnavailable => _t('imageUnavailable');
  String get memoryImage => _t('memoryImage');
  String get noImageAttached => _t('noImageAttached');
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
