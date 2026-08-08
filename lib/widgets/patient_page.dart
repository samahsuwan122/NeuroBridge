import 'package:flutter/material.dart';

class PatientPage extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const PatientPage({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(
      18,
      18,
      18,
      100,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(
        0xFFFFF8FA,
      ),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),
          padding: padding,
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 650,
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
  final EdgeInsetsGeometry padding;

  const NeuroCard({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.padding =
        const EdgeInsets.all(17),
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: const Color(
            0xFFEAD8DD,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFFB87585,
            ).withValues(
              alpha: 0.04,
            ),
            blurRadius: 16,
            offset: const Offset(
              0,
              6,
            ),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(22),
        onTap: onTap,
        child: content,
      ),
    );
  }
}

class PatientSectionTitle
    extends StatelessWidget {
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
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w900,
              color: Color(
                0xFF4F3C38,
              ),
            ),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              action!,
              style: const TextStyle(
                color: Color(
                  0xFF95606D,
                ),
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}