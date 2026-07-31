import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../models/sponsorship.dart';

class SponsorshipTierBadge extends StatelessWidget {
  const SponsorshipTierBadge({super.key, required this.tier});

  final SponsorshipTier tier;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (color, icon) = switch (tier) {
      SponsorshipTier.gold => (
          isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
          Icons.workspace_premium_rounded,
        ),
      SponsorshipTier.silver => (
          isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
          Icons.military_tech_rounded,
        ),
      SponsorshipTier.bronze => (
          isDark ? const Color(0xFFF97316) : const Color(0xFFB45309),
          Icons.stars_rounded,
        ),
    };

    final backgroundColor = color.withValues(alpha: isDark ? 0.2 : 0.12);
    final borderColor = color.withValues(alpha: isDark ? 0.5 : 0.4);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            tier.label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
