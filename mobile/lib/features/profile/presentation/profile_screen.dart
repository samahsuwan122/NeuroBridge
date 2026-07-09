import 'package:flutter/material.dart';

import '../../../core/app_scope.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/language_button.dart';
import '../../../core/widgets/loading_state.dart';
import '../application/profile_controller.dart';
import '../data/patient_profile_detail.dart';

/// Read-only patient profile. Basic profile fields only — no diagnosis, notes,
/// or medical interpretation. Editing is not available in this phase.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppScope.of(context).profile.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = AppScope.of(context).profile;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myProfile),
        actions: const [LanguageButton()],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: AnimatedBuilder(
              animation: profile,
              builder: (context, _) => _body(context, profile, l10n),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    ProfileController profile,
    AppLocalizations l10n,
  ) {
    switch (profile.status) {
      case ProfileStatus.initial:
      case ProfileStatus.loading:
        return Center(child: LoadingState(message: l10n.loadingProfile));
      case ProfileStatus.error:
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ErrorState(
            message: l10n.profileLoadFailed,
            retryLabel: l10n.retry,
            onRetry: profile.load,
          ),
        );
      case ProfileStatus.empty:
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(l10n.noPatientProfile, textAlign: TextAlign.center),
          ),
        );
      case ProfileStatus.loaded:
        return _ProfileView(profile: profile.profile!, l10n: l10n);
    }
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView({required this.profile, required this.l10n});

  final PatientProfileDetail profile;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.profileSubtitle,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _InfoRow(label: l10n.fullName, value: profile.fullName, l10n: l10n),
                const Divider(),
                _InfoRow(label: l10n.email, value: profile.email, l10n: l10n),
                const Divider(),
                _InfoRow(label: l10n.phone, value: profile.phone, l10n: l10n),
                const Divider(),
                _InfoRow(
                    label: l10n.dateOfBirth,
                    value: profile.dateOfBirthDisplay,
                    l10n: l10n),
                const Divider(),
                _InfoRow(label: l10n.gender, value: profile.gender, l10n: l10n),
                const Divider(),
                _InfoRow(
                    label: l10n.emergencyContact,
                    value: profile.emergencyContactDisplay,
                    l10n: l10n),
                const Divider(),
                _InfoRow(
                    label: l10n.memberSince,
                    value: profile.memberSinceDisplay,
                    l10n: l10n),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, required this.l10n});

  final String label;
  final String? value;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final display = (value == null || value!.isEmpty) ? l10n.notProvided : value!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium
                ?.copyWith(color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 2),
          Text(display, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
