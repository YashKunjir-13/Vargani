import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/semantic_colors.dart';
import '../chips/status_chip.dart';

/// A budget-category-shaped row: icon, name, a utilization bar, and the
/// spent/allocated figures underneath.
///
/// Used by the Budget module's category list, and reused read-only by the
/// Dashboard's analytics drill-down when it links back to a budget category
/// -- one implementation, two contexts.
class AllocationCard extends StatelessWidget {
  final IconData icon;
  final String name;

  /// 0.0-1.0+ (values >= 1.0 render as over-budget).
  final double progress;

  final String spentLabel;
  final String allocatedLabel;

  /// Typically a [StatusChip] built with [statusForProgress].
  final Widget? trailing;

  /// Short note under the figures, e.g. "under-used".
  final String? footnote;

  final VoidCallback? onTap;

  const AllocationCard({
    super.key,
    required this.icon,
    required this.name,
    required this.progress,
    required this.spentLabel,
    required this.allocatedLabel,
    this.trailing,
    this.footnote,
    this.onTap,
  });

  /// The approved allocation threshold rule: under 80% is healthy, 80-99%
  /// is a warning, 100%+ is over budget. Exposed statically so callers
  /// building a matching [StatusChip] badge use the same thresholds this
  /// card uses for its own progress bar color.
  static StatusChipType statusForProgress(double progress) {
    if (progress >= 1.0) return StatusChipType.error;
    if (progress >= 0.8) return StatusChipType.warning;
    return StatusChipType.success;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<SemanticColors>()!;
    final textTheme = Theme.of(context).textTheme;

    final barColor = switch (statusForProgress(progress)) {
      StatusChipType.error => colorScheme.error,
      StatusChipType.warning => semantic.warning,
      _ => semantic.success,
    };

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Icon(icon,
              size: AppIconSize.small, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(width: AppSpacing.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              const SizedBox(height: AppSpacing.space4),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(barColor),
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '$spentLabel spent',
                      style: textTheme.bodyMedium
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'of $allocatedLabel${footnote != null ? ' · $footnote' : ''}',
                      textAlign: TextAlign.end,
                      style: textTheme.bodyMedium
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.small),
      child: content,
    );
  }
}
