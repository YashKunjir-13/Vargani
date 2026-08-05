import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

/// The three sizes [LoadingIndicator] renders at.
enum LoadingIndicatorSize { small, medium, large }

/// A themed, consistently-sized spinner wrapping [CircularProgressIndicator].
///
/// Exists so every inline/button/section loading spinner in the app uses the
/// same three diameters and the same default color, instead of each call
/// site picking its own size and color by hand.
class LoadingIndicator extends StatelessWidget {
  final LoadingIndicatorSize size;

  /// Overrides the indicator color. Defaults to [ColorScheme.primary].
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.size = LoadingIndicatorSize.medium,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final diameter = switch (size) {
      LoadingIndicatorSize.small => AppIconSize.small,
      LoadingIndicatorSize.medium => AppIconSize.large,
      LoadingIndicatorSize.large => AppIconSize.extraLarge,
    };

    return SizedBox(
      width: diameter,
      height: diameter,
      child: CircularProgressIndicator(
        strokeWidth: diameter / 8,
        color: color ?? Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
