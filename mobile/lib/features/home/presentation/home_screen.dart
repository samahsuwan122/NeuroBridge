import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_scope.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/dashboard_card.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/language_button.dart';
import '../../../core/widgets/loading_state.dart';
import '../../auth/application/auth_controller.dart';
import '../application/home_controller.dart';

const _patientRole = 'patient';
const _familyRole = 'family';

/// Patient/family home screen: header, patient summary, and dashboard cards.
/// Dashboard cards are elderly-friendly placeholders ("Coming soon") — no real
/// games/therapy/progress logic here.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load the profile summary after first frame (only for patient/family).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final scope = AppScope.of(context);
      final roles = scope.auth.user?.roles ?? const <String>[];
      if (roles.contains(_patientRole) || roles.contains(_familyRole)) {
        scope.home.load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: const [LanguageButton()],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(auth: scope.auth, l10n: l10n),
                  const SizedBox(height: 16),
                  _SummarySection(
                    auth: scope.auth,
                    home: scope.home,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 8),
                  ..._dashboardCards(context, l10n),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _dashboardCards(BuildContext context, AppLocalizations l10n) {
    return [
      DashboardCard(
        icon: Icons.self_improvement,
        title: l10n.todayTherapy,
        description: l10n.todayTherapyDesc,
        comingSoonLabel: l10n.comingSoon,
      ),
      DashboardCard(
        icon: Icons.videogame_asset,
        title: l10n.cognitiveGames,
        description: l10n.cognitiveGamesDesc,
        comingSoonLabel: l10n.comingSoon,
        enabled: true,
        onTap: () => context.go('/games'),
      ),
      DashboardCard(
        icon: Icons.show_chart,
        title: l10n.progress,
        description: l10n.progressDesc,
        comingSoonLabel: l10n.comingSoon,
        enabled: true,
        onTap: () => context.go('/progress'),
      ),
      DashboardCard(
        icon: Icons.alarm,
        title: l10n.reminders,
        description: l10n.remindersDesc,
        comingSoonLabel: l10n.comingSoon,
      ),
      DashboardCard(
        icon: Icons.person,
        title: l10n.myProfile,
        description: l10n.myProfileDesc,
        comingSoonLabel: l10n.comingSoon,
        enabled: true,
        onTap: () => context.go('/profile'),
      ),
      DashboardCard(
        icon: Icons.family_restroom,
        title: l10n.familySupport,
        description: l10n.familySupportDesc,
        comingSoonLabel: l10n.comingSoon,
      ),
    ];
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.auth, required this.l10n});

  final AuthController auth;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: auth,
      builder: (context, _) {
        final user = auth.user;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.appTitle, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              '${l10n.welcome}, ${user?.fullName ?? ''}',
              style: theme.textTheme.titleLarge,
            ),
            if (user != null && user.roles.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '${l10n.rolesLabel}: ${user.roles.join(', ')}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: auth.logout,
              icon: const Icon(Icons.logout),
              label: Text(l10n.logoutButton),
            ),
          ],
        );
      },
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({
    required this.auth,
    required this.home,
    required this.l10n,
  });

  final AuthController auth;
  final HomeController home;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final roles = auth.user?.roles ?? const <String>[];
    final isPatientOrFamily =
        roles.contains(_patientRole) || roles.contains(_familyRole);
    if (!isPatientOrFamily) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AnimatedBuilder(
          animation: home,
          builder: (context, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.patientSummary, style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                _body(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    switch (home.status) {
      case HomeStatus.initial:
      case HomeStatus.loading:
        return const LoadingState();
      case HomeStatus.error:
        return ErrorState(
          message: l10n.profileLoadError,
          retryLabel: l10n.retry,
          onRetry: home.load,
        );
      case HomeStatus.empty:
        return Text(l10n.noPatientProfile);
      case HomeStatus.loaded:
        final summary = home.summary!;
        final theme = Theme.of(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((summary.patientName ?? '').isNotEmpty)
              Text(summary.patientName!, style: theme.textTheme.titleMedium),
            if ((summary.medicalCenterId ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('${l10n.medicalCenter}: ${summary.medicalCenterId}'),
            ],
            if (summary.hasEmergencyContact) ...[
              const SizedBox(height: 6),
              Text(
                '${l10n.emergencyContact}: ${summary.emergencyContactDisplay}',
              ),
            ],
          ],
        );
    }
  }
}
