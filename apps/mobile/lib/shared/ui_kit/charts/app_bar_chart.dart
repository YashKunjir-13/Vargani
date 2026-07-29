import 'package:flutter/material.dart';

/// One labeled bar, or a pair of stacked/grouped values (e.g. allocated vs.
/// spent) for a single category on an [AppBarChart].
@immutable
class BarGroup {
  final String label;
  final double primaryValue;
  final double? comparisonValue;

  const BarGroup({required this.label, required this.primaryValue, this.comparisonValue});
}

/// A grouped/comparison bar chart -- used wherever the design system calls
/// for a "Bar Chart" (answers a comparison question, e.g. budget vs. actual,
/// or which sub-category is largest).
///
/// When [BarGroup.comparisonValue] is set, each group renders two bars
/// (comparison color behind, primary color in front) side by side.
class AppBarChart extends StatelessWidget {
  final List<BarGroup> groups;
  final Color primaryColor;
  final Color? comparisonColor;
  final double height;

  const AppBarChart({
    super.key,
    required this.groups,
    required this.primaryColor,
    this.comparisonColor,
    this.height = 110,
  });

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) return SizedBox(height: height);

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final maxValue = groups
        .map((g) => [g.primaryValue, g.comparisonValue ?? 0].reduce((a, b) => a > b ? a : b))
        .reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final group in groups)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (group.comparisonValue != null) ...[
                          _Bar(
                            heightFraction: maxValue == 0 ? 0 : group.comparisonValue! / maxValue,
                            color: comparisonColor ?? colorScheme.outlineVariant,
                            maxHeight: height,
                          ),
                          const SizedBox(width: 3),
                        ],
                        _Bar(
                          heightFraction: maxValue == 0 ? 0 : group.primaryValue / maxValue,
                          color: primaryColor,
                          maxHeight: height,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            for (final group in groups)
              Expanded(
                child: Text(
                  group.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final double heightFraction;
  final Color color;
  final double maxHeight;

  const _Bar({required this.heightFraction, required this.color, required this.maxHeight});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
      child: Container(
        width: 14,
        height: (maxHeight * heightFraction.clamp(0.0, 1.0)).clamp(2.0, maxHeight),
        color: color,
      ),
    );
  }
}
