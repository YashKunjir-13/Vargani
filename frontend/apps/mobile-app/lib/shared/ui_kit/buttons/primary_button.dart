import 'package:flutter/material.dart';

import '../surfaces/loading_indicator.dart';

/// The app's single primary (filled) button.
///
/// Wraps native [FilledButton]/[FilledButton.icon] rather than reinventing
/// button visuals -- the value this widget adds is a consistent built-in
/// loading state and an [expand] (full-width) option, both needed
/// repeatedly across sticky action bars and bottom sheets.
///
/// Per the design system, a screen or section should never show more than
/// one [PrimaryButton] at a time -- pair it with [SecondaryButton] or a
/// plain [TextButton] for secondary/tertiary actions instead.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// Shows a spinner in place of the label and disables the button.
  final bool isLoading;

  /// Stretches the button to fill its parent's width.
  final bool expand;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget button;

    if (isLoading) {
      button = FilledButton(
        onPressed: null,
        child: LoadingIndicator(
          size: LoadingIndicatorSize.small,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      );
    } else if (icon != null) {
      button = FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      );
    } else {
      button = FilledButton(
        onPressed: onPressed,
        child: Text(label),
      );
    }

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
