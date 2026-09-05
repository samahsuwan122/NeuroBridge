import 'package:flutter/material.dart';

import '/core/theme/app_colors.dart';

class PatientPage extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const PatientPage({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 18, 20, 30),
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0xFF17120F), Color(0xFF201713), Color(0xFF2B1E18)]
              : const [AppColors.backgroundWarm, AppColors.backgroundSoft, AppColors.backgroundTint],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: padding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1080,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class NeuroCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final bool featured;
  final EdgeInsetsGeometry padding;

  const NeuroCard({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.featured = false,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? (dark ? const Color(0xFF241B16) : AppColors.surface.withValues(alpha: .94)),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: featured
              ? scheme.secondary.withValues(alpha: .48)
              : (dark ? const Color(0xFF5A4031) : AppColors.border),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: featured ? .12 : .065),
            blurRadius: featured ? 24 : 14,
            offset: Offset(0, featured ? 10 : 5),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(23),
        onTap: onTap,
        child: card,
      ),
    );
  }
}

class PatientSectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const PatientSectionTitle({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary)),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              action!,
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}
