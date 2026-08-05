import 'package:flutter/material.dart';

/// A trend line chart with a faint grid, a translucent area fill, and an
/// end-point marker -- used wherever the design system calls for a "Line
/// Chart" (answers "is this trending up or down over time").
///
/// [color] is deliberately required rather than defaulted: the chart itself
/// carries no semantic meaning (a collection trend might be colored with
/// success, an expense trend with error) -- that choice belongs to the
/// caller, not this widget.
///
/// [highlightIndex]/[highlightLabel] optionally render a callout bubble over
/// one data point (e.g. "the point the user tapped"), reused by both the
/// Dashboard trend chart and the KPI Detail screen's interactive chart.
class AppLineChart extends StatelessWidget {
  final List<double> values;
  final Color color;
  final double height;
  final int? highlightIndex;
  final String? highlightLabel;

  const AppLineChart({
    super.key,
    required this.values,
    required this.color,
    this.height = 130,
    this.highlightIndex,
    this.highlightLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return SizedBox(height: height);
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _LineChartPainter(
          values: values,
          color: color,
          gridColor: colorScheme.outlineVariant,
          highlightIndex: highlightIndex,
          highlightLabel: highlightLabel,
          labelStyle: textTheme.labelSmall,
          labelBackground: colorScheme.inverseSurface,
          labelColor: colorScheme.onInverseSurface,
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final Color gridColor;
  final int? highlightIndex;
  final String? highlightLabel;
  final TextStyle? labelStyle;
  final Color labelBackground;
  final Color labelColor;

  _LineChartPainter({
    required this.values,
    required this.color,
    required this.gridColor,
    required this.highlightIndex,
    required this.highlightLabel,
    required this.labelStyle,
    required this.labelBackground,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final chartHeight = size.height - 24; // reserve top space for a callout bubble
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final range = (maxValue - minValue).abs() < 1e-9 ? 1 : maxValue - minValue;
    final stepX = size.width / (values.length - 1).clamp(1, double.infinity);

    double yFor(double value) => 24 + chartHeight * (1 - (value - minValue) / range);

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (final fraction in [0.25, 0.5, 0.75]) {
      final y = 24 + chartHeight * fraction;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final point = Offset(i * stepX, yFor(values[i]));
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    final fillPath = Path.from(path)
      ..lineTo((values.length - 1) * stepX, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(fillPath, Paint()..color = color.withValues(alpha: 0.12));
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final endPoint = Offset((values.length - 1) * stepX, yFor(values.last));
    canvas.drawCircle(endPoint, 4, Paint()..color = color);

    if (highlightIndex != null && highlightLabel != null) {
      final point = Offset(highlightIndex! * stepX, yFor(values[highlightIndex!]));
      canvas.drawCircle(point, 4, Paint()..color = color);

      final textPainter = TextPainter(
        text: TextSpan(text: highlightLabel, style: labelStyle?.copyWith(color: labelColor)),
        textDirection: TextDirection.ltr,
      )..layout();

      final bubbleWidth = textPainter.width + 16;
      const bubbleHeight = 20.0;
      var bubbleLeft = point.dx - bubbleWidth / 2;
      bubbleLeft = bubbleLeft.clamp(0, size.width - bubbleWidth);
      final bubbleRect = Rect.fromLTWH(bubbleLeft, 0, bubbleWidth, bubbleHeight);

      canvas.drawRRect(
        RRect.fromRectAndRadius(bubbleRect, const Radius.circular(6)),
        Paint()..color = labelBackground,
      );
      textPainter.paint(
        canvas,
        Offset(bubbleRect.left + 8, bubbleRect.top + (bubbleHeight - textPainter.height) / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.color != color ||
        oldDelegate.highlightIndex != highlightIndex;
  }
}
