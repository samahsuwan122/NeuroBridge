import 'package:flutter/material.dart';

enum AppLanguage {
  english,
  arabic,
  french,
  spanish,
  german,
  turkish,
}

extension AppLanguageExtension on AppLanguage {
  String get code {
    switch (this) {
      case AppLanguage.english:
        return 'EN';

      case AppLanguage.arabic:
        return 'AR';

      case AppLanguage.french:
        return 'FR';

      case AppLanguage.spanish:
        return 'ES';

      case AppLanguage.german:
        return 'DE';

      case AppLanguage.turkish:
        return 'TR';
    }
  }

  String get name {
    switch (this) {
      case AppLanguage.english:
        return 'English';

      case AppLanguage.arabic:
        return 'العربية';

      case AppLanguage.french:
        return 'Français';

      case AppLanguage.spanish:
        return 'Español';

      case AppLanguage.german:
        return 'Deutsch';

      case AppLanguage.turkish:
        return 'Türkçe';
    }
  }

  TextDirection get direction {
    if (this == AppLanguage.arabic) {
      return TextDirection.rtl;
    }

    return TextDirection.ltr;
  }
}