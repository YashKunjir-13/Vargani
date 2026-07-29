import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, text }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.variant = AppButtonVariant.primary,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
  });

  final String label;
  final AppButtonVariant variant;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(label, overflow: TextOverflow.ellipsis),
        ),
      ],
    );

    final button = switch (variant) {
      AppButtonVariant.primary =>
        ElevatedButton(onPressed: onPressed, child: child),
      AppButtonVariant.secondary =>
        OutlinedButton(onPressed: onPressed, child: child),
      AppButtonVariant.text => TextButton(onPressed: onPressed, child: child),
    };

    if (!fullWidth) {
      return button;
    }

    return SizedBox(width: double.infinity, child: button);
  }
}
