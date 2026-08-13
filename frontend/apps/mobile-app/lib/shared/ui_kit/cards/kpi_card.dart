import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/semantic_colors.dart';
import '../charts/mini_sparkline.dart';
import '../surfaces/skeleton_block.dart';
import 'app_card.dart';

/// Numeric direction of a [KpiTrend] -- purely "did the number go up or
/// down," independent of whether that's good news.
enum TrendDirection { up, down }

/// Whether a [KpiTrend] is good, bad, or neither for this specific metric.
///
/// Kept separate from [TrendDirection] because the same direction can mean
/// opposite things: a rising "Total Collection" is [positive], but a rising
/// "Total Expense" is [negative] -- the arrow still points up either way.
enum TrendSentiment { positive, negative, neutral }

/// The trend indicator shown at the top of a [KpiCard].
@immutable
class KpiTrend {
  final TrendDirection direction;
  final String label;
  final TrendSentiment sentiment;

  const KpiTrend({
    required this.direction,
    required this.label,
    this.sentiment = TrendSentiment.positive,
  });
}

/// The primary financial/operational metric tile used across the Dashboard
/// and Budget modules.
///
/// Composes [AppCard] + [MiniSparkline] rather than owning its own surface
/// styling, and reuses [SkeletonBlock] for [isLoading] rather than a
/// bespoke shimmer -- both to avoid duplicating what those components
/// already do.
class KpiCard extends StatelessWidget {
  /// Short uppercase-style label, e.g. "TOTAL COLLECTION".
  final String label;

  /// The pre-formatted value, e.g. "₹18.43L".
  final String value;

  /// Optional trend indicator shown beside the label.
  final KpiTrend? trend;

  /// Optional badge shown instead of [trend] (e.g. a health [StatusChip]);
  /// when both are provided, [statusBadge] takes the label row's trailing slot.
  final Widget? statusBadge;

  /// Optional sparkline/progress data rendered below the value.
  final List<double>? sparklineValues;
  final Color? sparklineColor;

  /// Short caption under the sparkline, e.g. "Updated 2 min ago".
  final String? caption;

  final VoidCallback? onTap;
  final bool isLoading;
  final bool isSelected;
  final bool isDisabled;

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    this.trend,
    this.statusBadge,
    this.sparklineValues,
    this.sparklineColor,
    this.caption,
    this.onTap,
    this.isLoading = false,
    this.isSelected = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget card = AppCard(
      onTap: isDisabled || isLoading ? null : onTap,
      child: isLoading ? _buildLoading() : _buildContent(context),
    );

    if (isSelected) {
      card = Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.medium + 2),
          border: Border.all(color: colorScheme.primary, width: 2),
        ),
        child: card,
      );
    }

    if (isDisabled) {
      card = Opacity(opacity: 0.45, child: card);
    }

    return card;
  }

  Widget _buildLoading() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBlock(width: 90, height: 12),
        SizedBox(height: AppSpacing.space8),
        SkeletonBlock(width: 120, height: 22),
        SizedBox(height: AppSpacing.space8),
        SkeletonBlock(height: 26),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final semantic = Theme.of(context).extension<SemanticColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                label,
                style: textTheme.labelMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ),
            if (statusBadge != null)
              statusBadge!
            else if (trend != null)
              _TrendLabel(trend: trend!),
          ],
        ),
        const SizedBox(height: AppSpacing.space4),
        Text(
          value,
          style: textTheme.titleLarge?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        if (sparklineValues != null) ...[
          const SizedBox(height: AppSpacing.space8),
          MiniSparkline(
            values: sparklineValues!,
            color: sparklineColor ?? semantic.success,
            height: 26,
          ),
        ],
        if (caption != null) ...[
          const SizedBox(height: AppSpacing.space4),
          Text(
            caption!,
            style: textTheme.labelSmall
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}

class _TrendLabel extends StatelessWidget {
  final KpiTrend trend;

  const _TrendLabel({required this.trend});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<SemanticColors>()!;
    final textTheme = Theme.of(context).textTheme;

    final color = switch (trend.sentiment) {
      TrendSentiment.positive => semantic.success,
      TrendSentiment.negative => colorScheme.error,
      TrendSentiment.neutral => colorScheme.onSurfaceVariant,
    };
    final icon = trend.direction == TrendDirection.up
        ? Icons.arrow_upward
        : Icons.arrow_downward;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 2),
        Text(trend.label,
            style: textTheme.labelSmall
                ?.copyWith(color: color, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
