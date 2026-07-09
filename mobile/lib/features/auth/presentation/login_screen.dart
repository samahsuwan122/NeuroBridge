import 'package:flutter/material.dart';

import '../../../core/app_scope.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/language_button.dart';

/// Login screen. On success, the router redirects to /home automatically
/// (it listens to the auth controller).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = AppScope.of(context).auth;
    await auth.login(
      _identifierController.text.trim(),
      _passwordController.text,
    );
    // Navigation is handled by the router redirect on auth state change.
  }

  @override
  Widget build(BuildContext context) {
    final auth = AppScope.of(context).auth;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.loginTitle),
        actions: const [LanguageButton()],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: AnimatedBuilder(
              animation: auth,
              builder: (context, _) {
                return Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 76,
                        width: 76,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.spa_rounded,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.appTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.loginSubtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: _identifierController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(labelText: l10n.emailOrPhone),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                                ? l10n.fieldRequired
                                : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(labelText: l10n.password),
                        validator: (value) =>
                            (value == null || value.isEmpty)
                                ? l10n.fieldRequired
                                : null,
                        onFieldSubmitted: (_) {
                          if (!auth.isLoading) _submit();
                        },
                      ),
                      const SizedBox(height: 12),
                      if (auth.errorCode != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            auth.errorCode == 'network'
                                ? l10n.networkError
                                : l10n.invalidLogin,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      FilledButton(
                        onPressed: auth.isLoading ? null : _submit,
                        child: auth.isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(l10n.loginButton),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
