import 'package:flutter/material.dart';

import '../surfaces/loading_indicator.dart';

/// The app's secondary (outlined) button -- pairs with [PrimaryButton] for
/// actions like "Cancel" / "Save Draft" / "Return" alongside a single
/// primary "Approve" / "Submit" / "Generate Export".
///
/// Wraps native [OutlinedButton]/[OutlinedButton.icon]; adds the same
/// built-in loading state and [expand] option as [PrimaryButton] for
/// consistency between the two.
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expand;

  const SecondaryButton({
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
      button = OutlinedButton(
        onPressed: null,
        child: LoadingIndicator(
          size: LoadingIndicatorSize.small,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    } else if (icon != null) {
      button = OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      );
    } else {
      button = OutlinedButton(
        onPressed: onPressed,
        child: Text(label),
      );
    }

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
