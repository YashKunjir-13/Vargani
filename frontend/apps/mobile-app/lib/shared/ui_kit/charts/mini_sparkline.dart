import 'package:flutter/material.dart';

/// Visual style for [MiniSparkline].
enum SparklineStyle { line, bar }

/// A compact trend chart for KPI cards and analytics tiles.
///
/// Animates in on first build/data change via a 0->1 [TweenAnimationBuilder]
/// driving the painter's `progress`, then repaints only when [values],
/// [color] or [style] actually change (see [_SparklinePainter.shouldRepaint]).
class MiniSparkline extends StatelessWidget {
  final List<double> values;
  final Color color;
  final SparklineStyle style;
  final List<String>? labels;
  final double height;

  const MiniSparkline({
    super.key,
    required this.values,
    required this.color,
    this.style = SparklineStyle.line,
    this.labels,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return SizedBox(height: height);
    }

    return TweenAnimationBuilder<double>(
      key: ValueKey(values),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, progress, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: height,
              width: double.infinity,
              child: CustomPaint(
                painter: _SparklinePainter(
                  values: values,
                  color: color,
                  style: style,
                  progress: progress,
                ),
              ),
            ),
            if (labels != null) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: labels!
                    .map((label) => Text(
                          label,
                          style: Theme.of(context).textTheme.labelSmall,
                        ))
                    .toList(),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final SparklineStyle style;
  final double progress;

  _SparklinePainter({
    required this.values,
    required this.color,
    required this.style,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final range = (maxValue - minValue).abs() < 1e-9 ? 1 : maxValue - minValue;

    double normalize(double value) => (value - minValue) / range;

    if (style == SparklineStyle.bar) {
      final barCount = values.length;
      final barWidth = size.width / (barCount * 1.6);
      final gap = (size.width - barWidth * barCount) /
          (barCount - 1).clamp(1, double.infinity);
      final paint = Paint()..color = color;

      for (var i = 0; i < barCount; i++) {
        final barHeight = size.height * normalize(values[i]) * progress;
        final left = i * (barWidth + gap);
        final rect = Rect.fromLTWH(
          left,
          size.height - barHeight,
          barWidth,
          barHeight,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(3)),
          paint,
        );
      }
      return;
    }

    final path = Path();
    final stepX = size.width / (values.length - 1).clamp(1, double.infinity);
    final visiblePoints =
        (values.length * progress).ceil().clamp(1, values.length);

    for (var i = 0; i < visiblePoints; i++) {
      final x = i * stepX;
      final y = size.height * (1 - normalize(values[i]));
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    final fillPath = Path.from(path)
      ..lineTo((visiblePoints - 1) * stepX, size.height)
      ..lineTo(0, size.height)
      ..close();
    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.values != values ||
        oldDelegate.color != color;
  }
}
