import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A wrapper widget that hides or disables actions based on user permissions.
class PermissionGuard extends ConsumerWidget {
  final bool hasPermission;
  final Widget child;
  final bool
      hideWhenUnauthorized; // If true, hides; if false, disables child with tooltip.
  final String fallbackTooltip;

  const PermissionGuard({
    super.key,
    required this.hasPermission,
    required this.child,
    this.hideWhenUnauthorized = false,
    this.fallbackTooltip =
        'Your current role lacks permission for this action.',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (hasPermission) {
      return child;
    }

    if (hideWhenUnauthorized) {
      return const SizedBox.shrink();
    }

    return Tooltip(
      message: '$fallbackTooltip (Switch role in header to test)',
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.4,
          child: child,
        ),
      ),
    );
  }
}
