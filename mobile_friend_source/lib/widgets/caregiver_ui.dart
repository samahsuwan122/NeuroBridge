import 'package:flutter/material.dart';

abstract final class CaregiverColors {
  static const rose = Color(0xFFB87585);
  static const roseDark = Color(0xFF95606D);
  static const brown = Color(0xFF4F3C38);
  static const muted = Color(0xFF89736F);
  static const border = Color(0xFFEAD8DD);

  static const blue = Color(0xFF7895A4);
  static const green = Color(0xFF789981);
  static const gold = Color(0xFFC79A62);
  static const purple = Color(0xFF9D7BB0);
}

class CaregiverPage extends StatelessWidget {
  final Widget child;

  const CaregiverPage({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFCFD),
            Color(0xFFFFF6F9),
            Color(0xFFFCECF1),
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            35,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
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

class CaregiverCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;

  const CaregiverCard({
    super.key,
    required this.child,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: color ??
            Colors.white.withValues(
              alpha: .80,
            ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: CaregiverColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: CaregiverColors.rose.withValues(
              alpha: .04,
            ),
            blurRadius: 18,
            offset: const Offset(0, 7),
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
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: card,
      ),
    );
  }
}

class CaregiverHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBack;

  const CaregiverHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showBack)
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_forward_ios_rounded,
            ),
          ),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  color: CaregiverColors.brown,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 5),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.6,
                    color: CaregiverColors.muted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class CaregiverMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const CaregiverMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CaregiverCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 53,
            height: 53,
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: .12,
              ),
              borderRadius:
                  BorderRadius.circular(17),
            ),
            child: Icon(
              icon,
              color: color,
              size: 27,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: CaregiverColors.brown,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.5,
                    color: CaregiverColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 15,
            color: Color(0xFFB5A2A6),
          ),
        ],
      ),
    );
  }
}