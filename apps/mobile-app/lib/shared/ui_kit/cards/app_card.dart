import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

/// The base surface every higher-level card (KPI cards, alert cards, chart
/// cards, ...) is built from: themed background, outline, radius and
/// elevation, with an optional tap ripple.
///
/// Kept deliberately content-agnostic -- [child] supplies everything else,
/// so this widget stays reusable across every module rather than assuming
/// any particular layout.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  /// When provided, the whole card becomes tappable with an MD3 ripple.
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      elevation: AppElevation.level1,
      // Keeps the exact approved surface color -- MD3's default tonal
      // elevation tint would otherwise shift it toward primary.
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppSpacing.space16),
          child: child,
        ),
      ),
    );
  }
}
