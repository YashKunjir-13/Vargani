import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../buttons/primary_button.dart';

/// The "never a blank screen" pattern: an icon, a headline, supporting
/// text explaining *why* there's nothing here, and an optional single
/// action guiding the user to the next step.
///
/// Reused for every empty-data case across all four modules (no
/// transactions, no budget, no milestones, no search results, ...) --
/// only the icon/copy/action change per call site.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  /// Label for the optional primary action. Must be paired with [onAction].
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  }) : assert(
          (actionLabel == null) == (onAction == null),
          'actionLabel and onAction must be provided together',
        );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space20,
          vertical: AppSpacing.space32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: AppIconSize.extraLarge,
                color: colorScheme.onSurfaceVariant),
            const SizedBox(height: AppSpacing.space12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: AppSpacing.space16),
              PrimaryButton(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}
