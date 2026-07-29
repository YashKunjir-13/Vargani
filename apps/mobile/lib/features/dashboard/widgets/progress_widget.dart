import 'package:flutter/material.dart';

class ProgressWidget extends StatelessWidget {
  final double value;
  final Color color;
  final bool showPercentageLabel;

  const ProgressWidget({
    super.key,
    required this.value,
    required this.color,
    this.showPercentageLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: clamped),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, _) => LinearProgressIndicator(
              value: animatedValue,
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        if (showPercentageLabel) ...[
          const SizedBox(height: 4),
          Text(
            '${(clamped * 100).toStringAsFixed(0)}% achieved',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ],
    );
  }
}
