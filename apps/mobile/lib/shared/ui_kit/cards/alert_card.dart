import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/semantic_colors.dart';

/// The three tones an [AlertCard] can be shown in. Deliberately excludes a
/// "success" tone -- alerts, by definition, are things needing attention.
enum AlertTone { critical, warning, info }

/// A flat, color-filled banner for critical alerts, health warnings, and
/// priority notifications -- always positioned above ordinary analytics in
/// the design system's page hierarchy.
///
/// Unlike [AppCard], this is intentionally borderless/flat (a filled
/// container, not an outlined surface) to read as more urgent than a
/// regular card, and it is always shown with both an icon and text -- an
/// alert should never rely on color alone to convey severity.
class AlertCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final AlertTone tone;

  /// Optional trailing label (e.g. "Review") shown when the whole card is
  /// tappable via [onTap].
  final String? actionLabel;
  final VoidCallback? onTap;

  const AlertCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.tone = AlertTone.warning,
    this.actionLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<SemanticColors>()!;
    final textTheme = Theme.of(context).textTheme;

    final (Color background, Color foreground) = switch (tone) {
      AlertTone.critical => (colorScheme.errorContainer, colorScheme.onErrorContainer),
      AlertTone.warning => (semantic.warningContainer, semantic.onWarningContainer),
      AlertTone.info => (semantic.infoContainer, semantic.onInfoContainer),
    };

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: AppIconSize.small, color: foreground),
              const SizedBox(width: AppSpacing.space8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.bodyLarge?.copyWith(color: foreground, fontWeight: FontWeight.w700),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: textTheme.bodyMedium?.copyWith(color: foreground.withValues(alpha: 0.85)),
                      ),
                  ],
                ),
              ),
              if (actionLabel != null)
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.space8),
                  child: Text(
                    actionLabel!,
                    style: textTheme.labelMedium?.copyWith(color: foreground),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
