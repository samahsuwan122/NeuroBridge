import 'package:flutter/material.dart';

import '../../../core/app_scope.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/language_button.dart';

/// Placeholder logged-in home. Patient/family features are added in later phases.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AppScope.of(context).auth;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: const [LanguageButton()],
      ),
      body: AnimatedBuilder(
        animation: auth,
        builder: (context, _) {
          final user = auth.user;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.appTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '${l10n.welcome}, ${user?.fullName ?? ''}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (user != null && user.roles.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('${l10n.rolesLabel}: ${user.roles.join(', ')}'),
                    ],
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: auth.logout,
                      icon: const Icon(Icons.logout),
                      label: Text(l10n.logoutButton),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
