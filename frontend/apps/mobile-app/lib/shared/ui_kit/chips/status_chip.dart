import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/semantic_colors.dart';

/// The status meanings [StatusChip] can express.
///
/// Colors are resolved from [SemanticColors] (success/warning/info/neutral)
/// or [ColorScheme.error] -- never a hardcoded [Color].
enum StatusChipType { success, warning, error, info, neutral }

/// A small color-coded pill communicating a status.
///
/// The [label] is always required and always rendered as text, so meaning
/// never depends on color alone -- this satisfies the design system's
/// "never communicate status using color alone" rule by construction.
/// [icon] is an optional enhancement for prominent contexts (critical
/// alerts, health banners); omit it for compact, space-constrained chips
/// (e.g. a percentage badge inside a KPI card).
///
/// Example:
/// ```dart
/// StatusChip(label: 'Over Budget', type: StatusChipType.error, icon: Icons.error_outline);
/// StatusChip(label: '104%', type: StatusChipType.error); // compact, no icon
/// ```
class StatusChip extends StatelessWidget {
  /// The status text.
  final String label;

  /// Which semantic meaning this chip expresses.
  final StatusChipType type;

  /// Optional leading icon. Omit in dense/inline contexts.
  final IconData? icon;

  const StatusChip({
    super.key,
    required this.label,
    required this.type,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<SemanticColors>()!;
    final textTheme = Theme.of(context).textTheme;

    final (Color background, Color foreground) = switch (type) {
      StatusChipType.success => (
          semantic.successContainer,
          semantic.onSuccessContainer
        ),
      StatusChipType.warning => (
          semantic.warningContainer,
          semantic.onWarningContainer
        ),
      StatusChipType.error => (
          colorScheme.errorContainer,
          colorScheme.onErrorContainer
        ),
      StatusChipType.info => (semantic.infoContainer, semantic.onInfoContainer),
      StatusChipType.neutral => (
          colorScheme.surfaceContainerHighest,
          colorScheme.onSurfaceVariant
        ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space12,
          vertical: AppSpacing.space4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: AppIconSize.compact, color: foreground),
              const SizedBox(width: AppSpacing.space4),
            ],
            Text(
              label,
              style: textTheme.labelMedium
                  ?.copyWith(color: foreground, letterSpacing: 0),
            ),
          ],
        ),
      ),
    );
  }
}
