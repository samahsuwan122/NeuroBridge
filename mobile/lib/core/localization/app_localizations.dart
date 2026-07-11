import 'package:flutter/widgets.dart';

/// A supported UI language (code + native display name).
class AppLanguage {
  const AppLanguage(this.code, this.name);
  final String code;
  final String name;
}

/// Self-contained localization for 10 languages. Only Arabic ('ar') is
/// right-to-left; Flutter applies direction automatically via
/// GlobalWidgetsLocalizations from the active locale. English is the fallback
/// for any string not yet translated in a given language.
class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// The supported languages, in display order (native names).
  static const List<AppLanguage> supportedLanguages = [
    AppLanguage('ar', 'العربية'),
    AppLanguage('en', 'English'),
    AppLanguage('fr', 'Français'),
    AppLanguage('es', 'Español'),
    AppLanguage('de', 'Deutsch'),
    AppLanguage('tr', 'Türkçe'),
    AppLanguage('pt', 'Português'),
    AppLanguage('it', 'Italiano'),
    AppLanguage('hi', 'हिन्दी'),
    AppLanguage('id', 'Bahasa Indonesia'),
  ];

  static const List<Locale> supportedLocales = [
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
    Locale('es'),
    Locale('de'),
    Locale('tr'),
    Locale('pt'),
    Locale('it'),
    Locale('hi'),
    Locale('id'),
  ];

  static const Map<String, Map<String, String>> _values = {
    'en': {
      'appTitle': 'NeuroBridge',
      'loginSubtitle': 'Bridging memory. Connecting lives.',
      'homeSupportiveMessage': 'Small steps every day make a difference.',
      'activities': 'Activities',
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
      'language': 'Language',
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
      // Progress analytics
      'performanceSummary': 'Performance summary',
      'progressAnalyticsNote':
          'Exercise performance summaries only, not a medical assessment.',
      'totalExercises': 'Total exercises',
      'completedExercises': 'Completed',
      'bestPerformance': 'Best',
      'averagePerformance': 'Average',
      'latestActivity': 'Latest activity',
      'gameBreakdown': 'Game breakdown',
      'recentActivity': 'Recent activity',
      'noResultsYet': 'No results yet.',
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
      // Memory Recall exercise
      'memoryRecall': 'Memory Recall',
      'memoryRecallSubtitle': 'Remember moments from your Memory Album.',
      'memoryRecallNote':
          'A supportive recall activity for family connection only.',
      'startMemoryRecall': 'Start Memory Recall',
      'whoIsThisPerson': 'Who is this person?',
      'whereWasThisMemory': 'Where was this memory?',
      'whatCategoryIsThisMemory': 'What category does this memory belong to?',
      'correct': 'Correct',
      'tryAgain': 'Try again',
      'nextQuestion': 'Next question',
      'finishExercise': 'Finish',
      'recallComplete': 'Exercise complete',
      'recallScore': 'Your score',
      'notEnoughMemories': 'Not enough memories yet',
      'addMoreMemoriesToStart': 'Add more memories to start this exercise.',
      'memoryRecallLoadFailed':
          'Could not start Memory Recall. Please try again.',
      // Reaction Time exercise
      'reactionTime': 'Reaction Time',
      'reactionTimeSubtitle': 'Tap as fast as you can when the signal appears.',
      'reactionTimeNote':
          'This activity measures game performance only and is not a medical assessment.',
      'startRound': 'Start round',
      'waitForSignal': 'Wait…',
      'tapNow': 'Tap now!',
      'tooSoon': 'Too soon! Wait for the signal.',
      'reactionTimeMs': 'Reaction time',
      'bestReaction': 'Best',
      'averageReaction': 'Average',
      'roundsCompleted': 'Rounds',
      'reactionComplete': 'Exercise complete',
      // Attention Tap exercise
      'attentionTap': 'Attention Tap',
      'attentionTapSubtitle': 'Tap the target and ignore the rest.',
      'attentionTapNote':
          'This activity measures game performance only and is not a medical assessment.',
      'startAttentionTap': 'Start',
      'tapTheTarget': 'Tap the target',
      'target': 'Target',
      'correctTap': 'Correct!',
      'missedTarget': 'That was not the target',
      'mistake': 'Mistake',
      'accuracy': 'Accuracy',
      'attentionComplete': 'Exercise complete',
      'correctCount': 'Correct',
      // Sequence Recall exercise
      'sequenceRecall': 'Sequence Recall',
      'sequenceRecallSubtitle': 'Watch the sequence, then repeat it in order.',
      'sequenceRecallNote':
          'This activity measures game performance only and is not a medical assessment.',
      'startSequenceRecall': 'Start',
      'watchSequence': 'Watch the sequence',
      'repeatSequence': 'Repeat the sequence',
      'correctSequence': 'Correct!',
      'wrongSequence': 'Not quite',
      'longestSequence': 'Longest',
      'sequenceComplete': 'Exercise complete',
    },
    'ar': {
      'appTitle': 'نيوروبريدج',
      'loginSubtitle': 'نجسر الذاكرة، ونصل الحياة.',
      'homeSupportiveMessage': 'خطوات صغيرة كل يوم تُحدث فرقًا.',
      'activities': 'الأنشطة',
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
      'language': 'اللغة',
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
      // Progress analytics
      'performanceSummary': 'ملخص الأداء',
      'progressAnalyticsNote': 'ملخصات أداء التمارين فقط، وليست تقييمًا طبيًا.',
      'totalExercises': 'إجمالي التمارين',
      'completedExercises': 'مكتملة',
      'bestPerformance': 'الأفضل',
      'averagePerformance': 'المتوسط',
      'latestActivity': 'أحدث نشاط',
      'gameBreakdown': 'تفصيل الألعاب',
      'recentActivity': 'النشاط الأخير',
      'noResultsYet': 'لا توجد نتائج بعد.',
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
      // Memory Recall exercise
      'memoryRecall': 'استرجاع الذكريات',
      'memoryRecallSubtitle': 'تذكّر لحظات من ألبوم ذكرياتك.',
      'memoryRecallNote': 'نشاط استذكار داعم للتواصل العائلي فقط.',
      'startMemoryRecall': 'ابدأ استرجاع الذكريات',
      'whoIsThisPerson': 'من هذا الشخص؟',
      'whereWasThisMemory': 'أين كانت هذه الذكرى؟',
      'whatCategoryIsThisMemory': 'إلى أي فئة تنتمي هذه الذكرى؟',
      'correct': 'إجابة صحيحة',
      'tryAgain': 'حاول مرة أخرى',
      'nextQuestion': 'السؤال التالي',
      'finishExercise': 'إنهاء',
      'recallComplete': 'اكتمل التمرين',
      'recallScore': 'نتيجتك',
      'notEnoughMemories': 'لا توجد ذكريات كافية بعد',
      'addMoreMemoriesToStart': 'أضف المزيد من الذكريات لبدء هذا التمرين.',
      'memoryRecallLoadFailed': 'تعذّر بدء استرجاع الذكريات. حاول مرة أخرى.',
      // Reaction Time exercise
      'reactionTime': 'زمن رد الفعل',
      'reactionTimeSubtitle': 'انقر بأسرع ما يمكن عند ظهور الإشارة.',
      'reactionTimeNote': 'يقيس هذا النشاط أداء اللعبة فقط وليس تقييمًا طبيًا.',
      'startRound': 'ابدأ الجولة',
      'waitForSignal': 'انتظر…',
      'tapNow': 'انقر الآن!',
      'tooSoon': 'مبكرًا جدًا! انتظر الإشارة.',
      'reactionTimeMs': 'زمن رد الفعل',
      'bestReaction': 'الأفضل',
      'averageReaction': 'المتوسط',
      'roundsCompleted': 'الجولات',
      'reactionComplete': 'اكتمل التمرين',
      // Attention Tap exercise
      'attentionTap': 'الانتباه والنقر',
      'attentionTapSubtitle': 'انقر على الهدف وتجاهل البقية.',
      'attentionTapNote': 'يقيس هذا النشاط أداء اللعبة فقط وليس تقييمًا طبيًا.',
      'startAttentionTap': 'ابدأ',
      'tapTheTarget': 'انقر على الهدف',
      'target': 'الهدف',
      'correctTap': 'صحيح!',
      'missedTarget': 'هذا ليس الهدف',
      'mistake': 'خطأ',
      'accuracy': 'الدقة',
      'attentionComplete': 'اكتمل التمرين',
      'correctCount': 'صحيح',
      // Sequence Recall exercise
      'sequenceRecall': 'تسلسل الذاكرة',
      'sequenceRecallSubtitle': 'شاهد التسلسل ثم كرّره بالترتيب.',
      'sequenceRecallNote': 'يقيس هذا النشاط أداء اللعبة فقط وليس تقييمًا طبيًا.',
      'startSequenceRecall': 'ابدأ',
      'watchSequence': 'شاهد التسلسل',
      'repeatSequence': 'كرّر التسلسل',
      'correctSequence': 'صحيح!',
      'wrongSequence': 'ليس تمامًا',
      'longestSequence': 'الأطول',
      'sequenceComplete': 'اكتمل التمرين',
    },
    // Curated translations for the main screens; any key not present here
    // falls back to English via _t().
    'fr': {
      'loginTitle': 'Se connecter',
      'emailOrPhone': 'E-mail ou téléphone',
      'password': 'Mot de passe',
      'loginButton': 'Se connecter',
      'loginSubtitle': 'Relier la mémoire. Connecter les vies.',
      'homeTitle': 'Accueil',
      'welcome': 'Bienvenue',
      'logoutButton': 'Se déconnecter',
      'todayTherapy': 'Thérapie du jour',
      'cognitiveGames': 'Jeux cognitifs',
      'gamesTitle': 'Jeux cognitifs',
      'progress': 'Progrès',
      'reminders': 'Rappels',
      'myProfile': 'Mon profil',
      'familySupport': 'Soutien familial',
      'memoryAlbum': 'Album de souvenirs',
      'activities': 'Activités',
      'comingSoon': 'Bientôt disponible',
      'patientSummary': 'Résumé du patient',
      'retry': 'Réessayer',
      'cancel': 'Annuler',
      'play': 'Jouer',
      'playAgain': 'Rejouer',
      'notProvided': 'Non fourni',
      'difficulty': 'Difficulté',
      'instructions': 'Instructions',
      'minutes': 'min',
      'gameDetails': 'Détails du jeu',
      'addMemory': 'Ajouter un souvenir',
      'saveMemory': 'Enregistrer le souvenir',
      'memoryDetails': 'Détails du souvenir',
      'chooseImage': 'Choisir une image',
      'imageAttached': 'Image jointe',
      'noMemoriesYet': "Aucun souvenir pour l'instant.",
      'performanceSummary': 'Résumé des performances',
      'totalExercises': 'Total des exercices',
      'completedExercises': 'Terminés',
      'bestPerformance': 'Meilleur',
      'averagePerformance': 'Moyenne',
      'latestActivity': 'Dernière activité',
      'gameBreakdown': 'Détail par jeu',
      'recentActivity': 'Activité récente',
      'noProgressYet':
          'Pas encore de résultats. Jouez à un jeu pour voir vos progrès ici.',
      'basicInformation': 'Informations de base',
      'careSafetyInformation': 'Informations de soin et de sécurité',
      'allergies': 'Allergies',
      'currentMedications': 'Médicaments actuels',
      'bloodType': 'Groupe sanguin',
      'fullName': 'Nom complet',
      'email': 'E-mail',
      'phone': 'Téléphone',
      'language': 'Langue',
      'startMemoryRecall': 'Commencer',
      'careSafetyNote':
          "Ce sont uniquement des informations de soin et de sécurité, pas un diagnostic médical.",
      'memoryAlbumNote':
          'Les souvenirs servent uniquement au lien familial et à des activités de rappel bienveillantes.',
      'progressAnalyticsNote':
          "Résumés de performance des exercices uniquement, pas une évaluation médicale.",
      'reactionTimeNote':
          "Cette activité mesure uniquement la performance de jeu et n'est pas une évaluation médicale.",
      'attentionTapNote':
          "Cette activité mesure uniquement la performance de jeu et n'est pas une évaluation médicale.",
      'sequenceRecallNote':
          "Cette activité mesure uniquement la performance de jeu et n'est pas une évaluation médicale.",
    },
    'es': {
      'loginTitle': 'Iniciar sesión',
      'emailOrPhone': 'Correo o teléfono',
      'password': 'Contraseña',
      'loginButton': 'Iniciar sesión',
      'loginSubtitle': 'Unir la memoria. Conectar vidas.',
      'homeTitle': 'Inicio',
      'welcome': 'Bienvenido',
      'logoutButton': 'Cerrar sesión',
      'todayTherapy': 'Terapia de hoy',
      'cognitiveGames': 'Juegos cognitivos',
      'gamesTitle': 'Juegos cognitivos',
      'progress': 'Progreso',
      'reminders': 'Recordatorios',
      'myProfile': 'Mi perfil',
      'familySupport': 'Apoyo familiar',
      'memoryAlbum': 'Álbum de recuerdos',
      'activities': 'Actividades',
      'comingSoon': 'Próximamente',
      'patientSummary': 'Resumen del paciente',
      'retry': 'Reintentar',
      'cancel': 'Cancelar',
      'play': 'Jugar',
      'playAgain': 'Jugar de nuevo',
      'notProvided': 'No proporcionado',
      'difficulty': 'Dificultad',
      'instructions': 'Instrucciones',
      'minutes': 'min',
      'gameDetails': 'Detalles del juego',
      'addMemory': 'Añadir recuerdo',
      'saveMemory': 'Guardar recuerdo',
      'memoryDetails': 'Detalles del recuerdo',
      'chooseImage': 'Elegir imagen',
      'imageAttached': 'Imagen adjunta',
      'noMemoriesYet': 'Aún no hay recuerdos.',
      'performanceSummary': 'Resumen de rendimiento',
      'totalExercises': 'Ejercicios totales',
      'completedExercises': 'Completados',
      'bestPerformance': 'Mejor',
      'averagePerformance': 'Promedio',
      'latestActivity': 'Última actividad',
      'gameBreakdown': 'Desglose por juego',
      'recentActivity': 'Actividad reciente',
      'noProgressYet':
          'Aún no hay resultados. Juega para ver tu progreso aquí.',
      'basicInformation': 'Información básica',
      'careSafetyInformation': 'Información de cuidado y seguridad',
      'allergies': 'Alergias',
      'currentMedications': 'Medicamentos actuales',
      'bloodType': 'Grupo sanguíneo',
      'fullName': 'Nombre completo',
      'email': 'Correo electrónico',
      'phone': 'Teléfono',
      'language': 'Idioma',
      'startMemoryRecall': 'Comenzar',
      'careSafetyNote':
          'Solo son datos de cuidado y seguridad, no un diagnóstico médico.',
      'memoryAlbumNote':
          'Los recuerdos son solo para la conexión familiar y actividades de recuerdo de apoyo.',
      'progressAnalyticsNote':
          'Solo resúmenes de rendimiento de los ejercicios, no una evaluación médica.',
      'reactionTimeNote':
          'Esta actividad mide solo el rendimiento del juego y no es una evaluación médica.',
      'attentionTapNote':
          'Esta actividad mide solo el rendimiento del juego y no es una evaluación médica.',
      'sequenceRecallNote':
          'Esta actividad mide solo el rendimiento del juego y no es una evaluación médica.',
    },
    'de': {
      'loginTitle': 'Anmelden',
      'emailOrPhone': 'E-Mail oder Telefon',
      'password': 'Passwort',
      'loginButton': 'Anmelden',
      'loginSubtitle': 'Erinnerung verbinden. Leben verbinden.',
      'homeTitle': 'Startseite',
      'welcome': 'Willkommen',
      'logoutButton': 'Abmelden',
      'todayTherapy': 'Heutige Therapie',
      'cognitiveGames': 'Kognitive Spiele',
      'gamesTitle': 'Kognitive Spiele',
      'progress': 'Fortschritt',
      'reminders': 'Erinnerungen',
      'myProfile': 'Mein Profil',
      'familySupport': 'Familienunterstützung',
      'memoryAlbum': 'Erinnerungsalbum',
      'activities': 'Aktivitäten',
      'comingSoon': 'Demnächst',
      'patientSummary': 'Patientenübersicht',
      'retry': 'Erneut versuchen',
      'cancel': 'Abbrechen',
      'play': 'Spielen',
      'playAgain': 'Nochmal spielen',
      'notProvided': 'Nicht angegeben',
      'difficulty': 'Schwierigkeit',
      'instructions': 'Anweisungen',
      'minutes': 'Min.',
      'gameDetails': 'Spieldetails',
      'addMemory': 'Erinnerung hinzufügen',
      'saveMemory': 'Erinnerung speichern',
      'memoryDetails': 'Erinnerungsdetails',
      'chooseImage': 'Bild auswählen',
      'imageAttached': 'Bild angehängt',
      'noMemoriesYet': 'Noch keine Erinnerungen.',
      'performanceSummary': 'Leistungsübersicht',
      'totalExercises': 'Übungen insgesamt',
      'completedExercises': 'Abgeschlossen',
      'bestPerformance': 'Beste',
      'averagePerformance': 'Durchschnitt',
      'latestActivity': 'Letzte Aktivität',
      'gameBreakdown': 'Aufschlüsselung nach Spiel',
      'recentActivity': 'Letzte Aktivitäten',
      'noProgressYet':
          'Noch keine Ergebnisse. Spiele ein Spiel, um deinen Fortschritt hier zu sehen.',
      'basicInformation': 'Grundinformationen',
      'careSafetyInformation': 'Pflege- und Sicherheitsinformationen',
      'allergies': 'Allergien',
      'currentMedications': 'Aktuelle Medikamente',
      'bloodType': 'Blutgruppe',
      'fullName': 'Vollständiger Name',
      'email': 'E-Mail',
      'phone': 'Telefon',
      'language': 'Sprache',
      'startMemoryRecall': 'Starten',
      'careSafetyNote':
          'Dies sind nur Pflege- und Sicherheitsangaben, keine medizinische Diagnose.',
      'memoryAlbumNote':
          'Erinnerungen dienen nur der familiären Verbindung und unterstützenden Erinnerungsaktivitäten.',
      'progressAnalyticsNote':
          'Nur Leistungsübersichten der Übungen, keine medizinische Beurteilung.',
      'reactionTimeNote':
          'Diese Aktivität misst nur die Spielleistung und ist keine medizinische Beurteilung.',
      'attentionTapNote':
          'Diese Aktivität misst nur die Spielleistung und ist keine medizinische Beurteilung.',
      'sequenceRecallNote':
          'Diese Aktivität misst nur die Spielleistung und ist keine medizinische Beurteilung.',
    },
    'tr': {
      'loginTitle': 'Giriş yap',
      'emailOrPhone': 'E-posta veya telefon',
      'password': 'Şifre',
      'loginButton': 'Giriş yap',
      'loginSubtitle': 'Belleği köprüle. Hayatları bağla.',
      'homeTitle': 'Ana sayfa',
      'welcome': 'Hoş geldiniz',
      'logoutButton': 'Çıkış yap',
      'todayTherapy': 'Bugünkü terapi',
      'cognitiveGames': 'Bilişsel oyunlar',
      'gamesTitle': 'Bilişsel oyunlar',
      'progress': 'İlerleme',
      'reminders': 'Hatırlatıcılar',
      'myProfile': 'Profilim',
      'familySupport': 'Aile desteği',
      'memoryAlbum': 'Anı albümü',
      'activities': 'Etkinlikler',
      'comingSoon': 'Yakında',
      'patientSummary': 'Hasta özeti',
      'retry': 'Yeniden dene',
      'cancel': 'İptal',
      'play': 'Oyna',
      'playAgain': 'Tekrar oyna',
      'notProvided': 'Belirtilmemiş',
      'difficulty': 'Zorluk',
      'instructions': 'Talimatlar',
      'minutes': 'dk',
      'gameDetails': 'Oyun ayrıntıları',
      'addMemory': 'Anı ekle',
      'saveMemory': 'Anıyı kaydet',
      'memoryDetails': 'Anı ayrıntıları',
      'chooseImage': 'Görsel seç',
      'imageAttached': 'Görsel eklendi',
      'noMemoriesYet': 'Henüz anı yok.',
      'performanceSummary': 'Performans özeti',
      'totalExercises': 'Toplam egzersiz',
      'completedExercises': 'Tamamlanan',
      'bestPerformance': 'En iyi',
      'averagePerformance': 'Ortalama',
      'latestActivity': 'Son etkinlik',
      'gameBreakdown': 'Oyun dökümü',
      'recentActivity': 'Son etkinlikler',
      'noProgressYet':
          'Henüz sonuç yok. İlerlemenizi burada görmek için bir oyun oynayın.',
      'basicInformation': 'Temel bilgiler',
      'careSafetyInformation': 'Bakım ve güvenlik bilgileri',
      'allergies': 'Alerjiler',
      'currentMedications': 'Mevcut ilaçlar',
      'bloodType': 'Kan grubu',
      'fullName': 'Ad soyad',
      'email': 'E-posta',
      'phone': 'Telefon',
      'language': 'Dil',
      'startMemoryRecall': 'Başla',
      'careSafetyNote':
          'Bunlar yalnızca bakım ve güvenlik bilgileridir, tıbbi teşhis değildir.',
      'memoryAlbumNote':
          'Anılar yalnızca aile bağı ve destekleyici hatırlama etkinlikleri içindir.',
      'progressAnalyticsNote':
          'Yalnızca egzersiz performans özetleri, tıbbi değerlendirme değildir.',
      'reactionTimeNote':
          'Bu etkinlik yalnızca oyun performansını ölçer ve tıbbi bir değerlendirme değildir.',
      'attentionTapNote':
          'Bu etkinlik yalnızca oyun performansını ölçer ve tıbbi bir değerlendirme değildir.',
      'sequenceRecallNote':
          'Bu etkinlik yalnızca oyun performansını ölçer ve tıbbi bir değerlendirme değildir.',
    },
    'pt': {
      'loginTitle': 'Entrar',
      'emailOrPhone': 'E-mail ou telefone',
      'password': 'Senha',
      'loginButton': 'Entrar',
      'loginSubtitle': 'Unindo a memória. Conectando vidas.',
      'homeTitle': 'Início',
      'welcome': 'Bem-vindo',
      'logoutButton': 'Sair',
      'todayTherapy': 'Terapia de hoje',
      'cognitiveGames': 'Jogos cognitivos',
      'gamesTitle': 'Jogos cognitivos',
      'progress': 'Progresso',
      'reminders': 'Lembretes',
      'myProfile': 'Meu perfil',
      'familySupport': 'Apoio familiar',
      'memoryAlbum': 'Álbum de memórias',
      'activities': 'Atividades',
      'comingSoon': 'Em breve',
      'patientSummary': 'Resumo do paciente',
      'retry': 'Tentar novamente',
      'cancel': 'Cancelar',
      'play': 'Jogar',
      'playAgain': 'Jogar novamente',
      'notProvided': 'Não informado',
      'difficulty': 'Dificuldade',
      'instructions': 'Instruções',
      'minutes': 'min',
      'gameDetails': 'Detalhes do jogo',
      'addMemory': 'Adicionar memória',
      'saveMemory': 'Salvar memória',
      'memoryDetails': 'Detalhes da memória',
      'chooseImage': 'Escolher imagem',
      'imageAttached': 'Imagem anexada',
      'noMemoriesYet': 'Ainda não há memórias.',
      'performanceSummary': 'Resumo de desempenho',
      'totalExercises': 'Total de exercícios',
      'completedExercises': 'Concluídos',
      'bestPerformance': 'Melhor',
      'averagePerformance': 'Média',
      'latestActivity': 'Última atividade',
      'gameBreakdown': 'Detalhamento por jogo',
      'recentActivity': 'Atividade recente',
      'noProgressYet':
          'Ainda não há resultados. Jogue para ver seu progresso aqui.',
      'basicInformation': 'Informações básicas',
      'careSafetyInformation': 'Informações de cuidado e segurança',
      'allergies': 'Alergias',
      'currentMedications': 'Medicamentos atuais',
      'bloodType': 'Tipo sanguíneo',
      'fullName': 'Nome completo',
      'email': 'E-mail',
      'phone': 'Telefone',
      'language': 'Idioma',
      'startMemoryRecall': 'Começar',
      'careSafetyNote':
          'São apenas informações de cuidado e segurança, não um diagnóstico médico.',
      'memoryAlbumNote':
          'As memórias servem apenas para a conexão familiar e atividades de recordação de apoio.',
      'progressAnalyticsNote':
          'Apenas resumos de desempenho dos exercícios, não uma avaliação médica.',
      'reactionTimeNote':
          'Esta atividade mede apenas o desempenho do jogo e não é uma avaliação médica.',
      'attentionTapNote':
          'Esta atividade mede apenas o desempenho do jogo e não é uma avaliação médica.',
      'sequenceRecallNote':
          'Esta atividade mede apenas o desempenho do jogo e não é uma avaliação médica.',
    },
    'it': {
      'loginTitle': 'Accedi',
      'emailOrPhone': 'Email o telefono',
      'password': 'Password',
      'loginButton': 'Accedi',
      'loginSubtitle': 'Unire la memoria. Collegare le vite.',
      'homeTitle': 'Home',
      'welcome': 'Benvenuto',
      'logoutButton': 'Esci',
      'todayTherapy': 'Terapia di oggi',
      'cognitiveGames': 'Giochi cognitivi',
      'gamesTitle': 'Giochi cognitivi',
      'progress': 'Progressi',
      'reminders': 'Promemoria',
      'myProfile': 'Il mio profilo',
      'familySupport': 'Supporto familiare',
      'memoryAlbum': 'Album dei ricordi',
      'activities': 'Attività',
      'comingSoon': 'Prossimamente',
      'patientSummary': 'Riepilogo del paziente',
      'retry': 'Riprova',
      'cancel': 'Annulla',
      'play': 'Gioca',
      'playAgain': 'Gioca di nuovo',
      'notProvided': 'Non fornito',
      'difficulty': 'Difficoltà',
      'instructions': 'Istruzioni',
      'minutes': 'min',
      'gameDetails': 'Dettagli del gioco',
      'addMemory': 'Aggiungi ricordo',
      'saveMemory': 'Salva ricordo',
      'memoryDetails': 'Dettagli del ricordo',
      'chooseImage': 'Scegli immagine',
      'imageAttached': 'Immagine allegata',
      'noMemoriesYet': 'Ancora nessun ricordo.',
      'performanceSummary': 'Riepilogo delle prestazioni',
      'totalExercises': 'Esercizi totali',
      'completedExercises': 'Completati',
      'bestPerformance': 'Migliore',
      'averagePerformance': 'Media',
      'latestActivity': 'Ultima attività',
      'gameBreakdown': 'Dettaglio per gioco',
      'recentActivity': 'Attività recente',
      'noProgressYet':
          'Ancora nessun risultato. Gioca per vedere qui i tuoi progressi.',
      'basicInformation': 'Informazioni di base',
      'careSafetyInformation': 'Informazioni di cura e sicurezza',
      'allergies': 'Allergie',
      'currentMedications': 'Farmaci attuali',
      'bloodType': 'Gruppo sanguigno',
      'fullName': 'Nome completo',
      'email': 'Email',
      'phone': 'Telefono',
      'language': 'Lingua',
      'startMemoryRecall': 'Inizia',
      'careSafetyNote':
          'Sono solo informazioni di cura e sicurezza, non una diagnosi medica.',
      'memoryAlbumNote':
          'I ricordi servono solo al legame familiare e ad attività di richiamo di supporto.',
      'progressAnalyticsNote':
          'Solo riepiloghi delle prestazioni degli esercizi, non una valutazione medica.',
      'reactionTimeNote':
          'Questa attività misura solo le prestazioni di gioco e non è una valutazione medica.',
      'attentionTapNote':
          'Questa attività misura solo le prestazioni di gioco e non è una valutazione medica.',
      'sequenceRecallNote':
          'Questa attività misura solo le prestazioni di gioco e non è una valutazione medica.',
    },
    'hi': {
      'loginTitle': 'साइन इन करें',
      'emailOrPhone': 'ईमेल या फ़ोन',
      'password': 'पासवर्ड',
      'loginButton': 'साइन इन करें',
      'loginSubtitle': 'स्मृति को जोड़ना। जीवन को जोड़ना।',
      'homeTitle': 'होम',
      'welcome': 'स्वागत है',
      'logoutButton': 'लॉग आउट',
      'todayTherapy': 'आज की थेरेपी',
      'cognitiveGames': 'संज्ञानात्मक खेल',
      'gamesTitle': 'संज्ञानात्मक खेल',
      'progress': 'प्रगति',
      'reminders': 'अनुस्मारक',
      'myProfile': 'मेरी प्रोफ़ाइल',
      'familySupport': 'पारिवारिक सहायता',
      'memoryAlbum': 'स्मृति एल्बम',
      'activities': 'गतिविधियाँ',
      'comingSoon': 'जल्द आ रहा है',
      'patientSummary': 'रोगी सारांश',
      'retry': 'पुनः प्रयास करें',
      'cancel': 'रद्द करें',
      'play': 'खेलें',
      'playAgain': 'फिर से खेलें',
      'notProvided': 'उपलब्ध नहीं',
      'difficulty': 'कठिनाई',
      'instructions': 'निर्देश',
      'minutes': 'मिनट',
      'gameDetails': 'खेल विवरण',
      'addMemory': 'स्मृति जोड़ें',
      'saveMemory': 'स्मृति सहेजें',
      'memoryDetails': 'स्मृति विवरण',
      'chooseImage': 'छवि चुनें',
      'imageAttached': 'छवि संलग्न',
      'noMemoriesYet': 'अभी तक कोई स्मृति नहीं।',
      'performanceSummary': 'प्रदर्शन सारांश',
      'totalExercises': 'कुल अभ्यास',
      'completedExercises': 'पूर्ण',
      'bestPerformance': 'सर्वश्रेष्ठ',
      'averagePerformance': 'औसत',
      'latestActivity': 'नवीनतम गतिविधि',
      'gameBreakdown': 'खेल विश्लेषण',
      'recentActivity': 'हाल की गतिविधि',
      'noProgressYet':
          'अभी तक कोई परिणाम नहीं। अपनी प्रगति यहाँ देखने के लिए कोई खेल खेलें।',
      'basicInformation': 'बुनियादी जानकारी',
      'careSafetyInformation': 'देखभाल और सुरक्षा जानकारी',
      'allergies': 'एलर्जी',
      'currentMedications': 'वर्तमान दवाएँ',
      'bloodType': 'रक्त समूह',
      'fullName': 'पूरा नाम',
      'email': 'ईमेल',
      'phone': 'फ़ोन',
      'language': 'भाषा',
      'startMemoryRecall': 'शुरू करें',
      'careSafetyNote':
          'ये केवल देखभाल और सुरक्षा संबंधी जानकारी हैं, कोई चिकित्सीय निदान नहीं।',
      'memoryAlbumNote':
          'यादें केवल पारिवारिक जुड़ाव और सहायक स्मरण गतिविधियों के लिए हैं।',
      'progressAnalyticsNote':
          'केवल अभ्यास प्रदर्शन का सारांश, कोई चिकित्सीय मूल्यांकन नहीं।',
      'reactionTimeNote':
          'यह गतिविधि केवल खेल प्रदर्शन मापती है और यह कोई चिकित्सीय मूल्यांकन नहीं है।',
      'attentionTapNote':
          'यह गतिविधि केवल खेल प्रदर्शन मापती है और यह कोई चिकित्सीय मूल्यांकन नहीं है।',
      'sequenceRecallNote':
          'यह गतिविधि केवल खेल प्रदर्शन मापती है और यह कोई चिकित्सीय मूल्यांकन नहीं है।',
    },
    'id': {
      'loginTitle': 'Masuk',
      'emailOrPhone': 'Email atau telepon',
      'password': 'Kata sandi',
      'loginButton': 'Masuk',
      'loginSubtitle': 'Menjembatani ingatan. Menghubungkan kehidupan.',
      'homeTitle': 'Beranda',
      'welcome': 'Selamat datang',
      'logoutButton': 'Keluar',
      'todayTherapy': 'Terapi hari ini',
      'cognitiveGames': 'Permainan kognitif',
      'gamesTitle': 'Permainan kognitif',
      'progress': 'Kemajuan',
      'reminders': 'Pengingat',
      'myProfile': 'Profil saya',
      'familySupport': 'Dukungan keluarga',
      'memoryAlbum': 'Album kenangan',
      'activities': 'Aktivitas',
      'comingSoon': 'Segera hadir',
      'patientSummary': 'Ringkasan pasien',
      'retry': 'Coba lagi',
      'cancel': 'Batal',
      'play': 'Main',
      'playAgain': 'Main lagi',
      'notProvided': 'Tidak tersedia',
      'difficulty': 'Tingkat kesulitan',
      'instructions': 'Petunjuk',
      'minutes': 'mnt',
      'gameDetails': 'Detail permainan',
      'addMemory': 'Tambah kenangan',
      'saveMemory': 'Simpan kenangan',
      'memoryDetails': 'Detail kenangan',
      'chooseImage': 'Pilih gambar',
      'imageAttached': 'Gambar terlampir',
      'noMemoriesYet': 'Belum ada kenangan.',
      'performanceSummary': 'Ringkasan performa',
      'totalExercises': 'Total latihan',
      'completedExercises': 'Selesai',
      'bestPerformance': 'Terbaik',
      'averagePerformance': 'Rata-rata',
      'latestActivity': 'Aktivitas terbaru',
      'gameBreakdown': 'Rincian permainan',
      'recentActivity': 'Aktivitas terkini',
      'noProgressYet':
          'Belum ada hasil. Mainkan permainan untuk melihat kemajuan Anda di sini.',
      'basicInformation': 'Informasi dasar',
      'careSafetyInformation': 'Informasi perawatan dan keselamatan',
      'allergies': 'Alergi',
      'currentMedications': 'Obat saat ini',
      'bloodType': 'Golongan darah',
      'fullName': 'Nama lengkap',
      'email': 'Email',
      'phone': 'Telepon',
      'language': 'Bahasa',
      'startMemoryRecall': 'Mulai',
      'careSafetyNote':
          'Ini hanya informasi perawatan dan keselamatan, bukan diagnosis medis.',
      'memoryAlbumNote':
          'Kenangan hanya untuk hubungan keluarga dan aktivitas mengingat yang mendukung.',
      'progressAnalyticsNote':
          'Hanya ringkasan performa latihan, bukan penilaian medis.',
      'reactionTimeNote':
          'Aktivitas ini hanya mengukur performa permainan dan bukan penilaian medis.',
      'attentionTapNote':
          'Aktivitas ini hanya mengukur performa permainan dan bukan penilaian medis.',
      'sequenceRecallNote':
          'Aktivitas ini hanya mengukur performa permainan dan bukan penilaian medis.',
    },
  };

  String _t(String key) =>
      _values[locale.languageCode]?[key] ?? _values['en']![key] ?? key;

  String get appTitle => _t('appTitle');
  String get loginSubtitle => _t('loginSubtitle');
  String get homeSupportiveMessage => _t('homeSupportiveMessage');
  String get activities => _t('activities');
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
  String get language => _t('language');

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

  String get performanceSummary => _t('performanceSummary');
  String get progressAnalyticsNote => _t('progressAnalyticsNote');
  String get totalExercises => _t('totalExercises');
  String get completedExercises => _t('completedExercises');
  String get bestPerformance => _t('bestPerformance');
  String get averagePerformance => _t('averagePerformance');
  String get latestActivity => _t('latestActivity');
  String get gameBreakdown => _t('gameBreakdown');
  String get recentActivity => _t('recentActivity');
  String get noResultsYet => _t('noResultsYet');

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

  String get memoryRecall => _t('memoryRecall');
  String get memoryRecallSubtitle => _t('memoryRecallSubtitle');
  String get memoryRecallNote => _t('memoryRecallNote');
  String get startMemoryRecall => _t('startMemoryRecall');
  String get whoIsThisPerson => _t('whoIsThisPerson');
  String get whereWasThisMemory => _t('whereWasThisMemory');
  String get whatCategoryIsThisMemory => _t('whatCategoryIsThisMemory');
  String get correct => _t('correct');
  String get tryAgain => _t('tryAgain');
  String get nextQuestion => _t('nextQuestion');
  String get finishExercise => _t('finishExercise');
  String get recallComplete => _t('recallComplete');
  String get recallScore => _t('recallScore');
  String get notEnoughMemories => _t('notEnoughMemories');
  String get addMoreMemoriesToStart => _t('addMoreMemoriesToStart');
  String get memoryRecallLoadFailed => _t('memoryRecallLoadFailed');

  String get reactionTime => _t('reactionTime');
  String get reactionTimeSubtitle => _t('reactionTimeSubtitle');
  String get reactionTimeNote => _t('reactionTimeNote');
  String get startRound => _t('startRound');
  String get waitForSignal => _t('waitForSignal');
  String get tapNow => _t('tapNow');
  String get tooSoon => _t('tooSoon');
  String get reactionTimeMs => _t('reactionTimeMs');
  String get bestReaction => _t('bestReaction');
  String get averageReaction => _t('averageReaction');
  String get roundsCompleted => _t('roundsCompleted');
  String get reactionComplete => _t('reactionComplete');

  String get attentionTap => _t('attentionTap');
  String get attentionTapSubtitle => _t('attentionTapSubtitle');
  String get attentionTapNote => _t('attentionTapNote');
  String get startAttentionTap => _t('startAttentionTap');
  String get tapTheTarget => _t('tapTheTarget');
  String get target => _t('target');
  String get correctTap => _t('correctTap');
  String get missedTarget => _t('missedTarget');
  String get mistake => _t('mistake');
  String get accuracy => _t('accuracy');
  String get attentionComplete => _t('attentionComplete');
  String get correctCount => _t('correctCount');

  String get sequenceRecall => _t('sequenceRecall');
  String get sequenceRecallSubtitle => _t('sequenceRecallSubtitle');
  String get sequenceRecallNote => _t('sequenceRecallNote');
  String get startSequenceRecall => _t('startSequenceRecall');
  String get watchSequence => _t('watchSequence');
  String get repeatSequence => _t('repeatSequence');
  String get correctSequence => _t('correctSequence');
  String get wrongSequence => _t('wrongSequence');
  String get longestSequence => _t('longestSequence');
  String get sequenceComplete => _t('sequenceComplete');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => const [
        'ar', 'en', 'fr', 'es', 'de', 'tr', 'pt', 'it', 'hi', 'id',
      ].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
