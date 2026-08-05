import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

/// A shimmering placeholder block for loading states.
///
/// [width]/[height] should always be sized to match the real content this
/// placeholder stands in for exactly, so resolving data never shifts layout.
///
/// Respects reduced-motion: when [MediaQueryData.disableAnimations] is set,
/// the shimmer animation is skipped in favor of a static block.
class SkeletonBlock extends StatefulWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonBlock({
    super.key,
    this.width,
    this.height = AppSpacing.space16,
    this.borderRadius,
  });

  @override
  State<SkeletonBlock> createState() => _SkeletonBlockState();
}

class _SkeletonBlockState extends State<SkeletonBlock> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.of(context).disableAnimations;
    if (_reduceMotion) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = widget.borderRadius ?? BorderRadius.circular(AppRadius.small);

    if (_reduceMotion) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(color: colorScheme.surfaceContainer, borderRadius: radius),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final sweep = _controller.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment(-1 - sweep * 2, 0),
              end: Alignment(1 - sweep * 2, 0),
              colors: [
                colorScheme.surfaceContainer,
                colorScheme.surfaceContainerHigh,
                colorScheme.surfaceContainer,
              ],
            ),
          ),
        );
      },
    );
  }
}
