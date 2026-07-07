import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../localization/app_localizations.dart';

/// App-bar action that toggles the app language between English and Arabic.
class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppScope.of(context).locale;
    final l10n = AppLocalizations.of(context);
    return TextButton(
      onPressed: locale.toggle,
      child: Text(l10n.languageToggle),
    );
  }
}
