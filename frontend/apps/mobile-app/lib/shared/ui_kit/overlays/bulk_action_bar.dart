import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

/// One action offered by a [BulkActionBar], e.g. "Archive" or "Export".
@immutable
class BulkAction {
  final String label;
  final VoidCallback onPressed;

  const BulkAction({required this.label, required this.onPressed});
}

/// The sticky "N selected, act on them" bar shown when a list enters
/// selection mode.
///
/// This is the **one** implementation shared by the Budget table's row
/// selection and the Notification feed's selection mode -- both need the
/// identical "count + actions + cancel" pattern, so neither module defines
/// its own.
///
/// Uses [ColorScheme.inverseSurface]/[onInverseSurface] -- MD3's slots for
/// exactly this "floating bar that should contrast with the page" case, on
/// both light and dark themes without a hardcoded dark color.
class BulkActionBar extends StatelessWidget {
  final int selectedCount;
  final List<BulkAction> actions;
  final VoidCallback? onCancel;

  const BulkActionBar({
    super.key,
    required this.selectedCount,
    required this.actions,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.inverseSurface,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      elevation: AppElevation.level2,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space8,
        ),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.space12,
          children: [
            Text(
              '$selectedCount selected',
              style: textTheme.labelLarge
                  ?.copyWith(color: colorScheme.onInverseSurface),
            ),
            for (final action in actions)
              TextButton(
                onPressed: action.onPressed,
                style: TextButton.styleFrom(
                    foregroundColor: colorScheme.onInverseSurface),
                child: Text(action.label),
              ),
            if (onCancel != null)
              TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                    foregroundColor: colorScheme.onInverseSurface),
                child: const Text('Cancel'),
              ),
          ],
        ),
      ),
    );
  }
}
