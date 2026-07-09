import 'package:flutter/material.dart';

import '../../../core/app_scope.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/emerald_panel.dart';
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

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [LanguageButton()],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: AnimatedBuilder(
                animation: auth,
                builder: (context, _) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Hero(l10n: l10n),
                      const SizedBox(height: 20),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(l10n.loginTitle,
                                    style: theme.textTheme.titleLarge),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _identifierController,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    labelText: l10n.emailOrPhone,
                                    prefixIcon: const Icon(Icons.person_outline),
                                  ),
                                  validator: (value) =>
                                      (value == null || value.trim().isEmpty)
                                          ? l10n.fieldRequired
                                          : null,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: l10n.password,
                                    prefixIcon: const Icon(Icons.lock_outline),
                                  ),
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
                                          color: theme.colorScheme.error),
                                    ),
                                  ),
                                FilledButton(
                                  onPressed: auth.isLoading ? null : _submit,
                                  child: auth.isLoading
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : Text(l10n.loginButton),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return EmeraldPanel(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          Container(
            height: 84,
            width: 84,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.softGold, width: 1.5),
            ),
            child: const Icon(
              Icons.psychology_alt_outlined,
              size: 44,
              color: AppColors.onHero,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.appTitle,
            textAlign: TextAlign.center,
            style: text.headlineMedium?.copyWith(
              color: AppColors.onHero,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.loginSubtitle,
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: AppColors.onHeroMuted),
          ),
        ],
      ),
    );
  }
}
