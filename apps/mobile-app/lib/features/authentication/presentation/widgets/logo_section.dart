import 'package:flutter/material.dart';

import 'auth_design_tokens.dart';

class LogoSection extends StatelessWidget {
  const LogoSection({
    super.key,
    this.compact = false,
    this.title,
    this.subtitle,
    this.icon = Icons.local_fire_department_outlined,
  });

  final bool compact;
  final String? title;
  final String? subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.authColors;
    final iconSize = compact ? 64.0 : 136.0;
    return Column(
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: colors.gold, width: compact ? 2 : 4),
          ),
          child: Center(
            child: Container(
              width: iconSize * .62,
              height: iconSize * .62,
              decoration: BoxDecoration(
                color: colors.brandOrange,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: iconSize * .34),
            ),
          ),
        ),
        if (title != null) ...[
          SizedBox(height: compact ? 16 : 24),
          Text(
            title!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.text,
              fontSize: compact ? 30 : 40,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.secondaryText,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
