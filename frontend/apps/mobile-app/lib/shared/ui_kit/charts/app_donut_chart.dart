import 'package:flutter/material.dart';

/// One slice of an [AppDonutChart]: a value, the color it renders in, and
/// the label a caller-built legend can show alongside it.
///
/// Kept as plain data (not a widget) so the legend itself stays entirely up
/// to the caller -- matching the approved design, where the ring and its
/// legend are two independent pieces of a `Row`, not one fused component.
@immutable
class DonutSlice {
  final String label;
  final double value;
  final Color color;

  const DonutSlice(
      {required this.label, required this.value, required this.color});
}

/// A donut chart for part-to-whole composition (e.g. expense distribution
/// by category) -- used when there are up to ~6 categories, per the design
/// system's chart-selection rule.
class AppDonutChart extends StatelessWidget {
  final List<DonutSlice> slices;
  final double size;
  final double strokeWidth;

  const AppDonutChart({
    super.key,
    required this.slices,
    this.size = 80,
    this.strokeWidth = 12,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutChartPainter(
          slices: slices,
          strokeWidth: strokeWidth,
          trackColor: colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<DonutSlice> slices;
  final double strokeWidth;
  final Color trackColor;

  _DonutChartPainter({
    required this.slices,
    required this.strokeWidth,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, 0, 6.28319, false, trackPaint);

    final total = slices.fold<double>(0, (sum, slice) => sum + slice.value);
    if (total <= 0) return;

    var startAngle = -1.5708; // start at 12 o'clock
    for (final slice in slices) {
      final sweep = (slice.value / total) * 6.28319;
      final slicePaint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, startAngle, sweep, false, slicePaint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.slices != slices;
  }
}
