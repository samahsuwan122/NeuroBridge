import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../localization/app_localizations.dart';

/// App-bar action that opens a picker to choose one of the supported languages.
/// Arabic uses RTL; the other languages use LTR (handled automatically by
/// Flutter from the active locale).
class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return IconButton(
      key: const Key('language_button'),
      icon: const Icon(Icons.translate),
      tooltip: l10n.language,
      onPressed: () => _showPicker(context),
    );
  }

  void _showPicker(BuildContext context) {
    final locale = AppScope.of(context).locale;
    final l10n = AppLocalizations.of(context);
    final current = locale.locale.languageCode;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(l10n.language,
                      style: theme.textTheme.titleMedium),
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final lang in AppLocalizations.supportedLanguages)
                      ListTile(
                        key: Key('lang_${lang.code}'),
                        title: Text(lang.name),
                        trailing: lang.code == current
                            ? Icon(Icons.check, color: theme.colorScheme.primary)
                            : null,
                        onTap: () {
                          locale.setLocale(Locale(lang.code));
                          Navigator.of(sheetContext).pop();
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
