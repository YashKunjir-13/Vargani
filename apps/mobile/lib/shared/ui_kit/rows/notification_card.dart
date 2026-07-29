import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../buttons/primary_button.dart';

/// One entry in the Notification Center feed.
///
/// Per the design system, a notification either earns a call-to-action or
/// it doesn't need a card at all -- [primaryActionLabel]/[secondaryActionLabel]
/// are capped at two, matching the approved "max 2 CTAs, never 2 filled"
/// rule. Selection-mode (bulk actions) and the unread indicator share the
/// same leading slot: only one is ever shown at a time.
class NotificationCard extends StatelessWidget {
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String description;

  /// Shows the unread dot when true and [onSelectedChanged] is null.
  final bool isUnread;

  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  /// When non-null, selection mode is active: a checkbox replaces the
  /// unread dot and [isSelected] controls its state.
  final ValueChanged<bool?>? onSelectedChanged;
  final bool isSelected;

  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.description,
    this.isUnread = false,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.onSelectedChanged,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final Widget leading;
    if (onSelectedChanged != null) {
      leading = Checkbox(value: isSelected, onChanged: onSelectedChanged);
    } else if (isUnread) {
      leading = Padding(
        padding: const EdgeInsets.only(top: 6, right: AppSpacing.space8),
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
        ),
      );
    } else {
      leading = const SizedBox(width: AppSpacing.space8 + 6);
    }

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        leading,
        Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(right: AppSpacing.space12),
          decoration: BoxDecoration(color: iconBackground, borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, size: AppIconSize.small, color: iconColor),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
              Text(description, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
              if (primaryActionLabel != null) ...[
                const SizedBox(height: AppSpacing.space8),
                Row(
                  children: [
                    PrimaryButton(label: primaryActionLabel!, onPressed: onPrimaryAction),
                    if (secondaryActionLabel != null) ...[
                      const SizedBox(width: AppSpacing.space8),
                      TextButton(onPressed: onSecondaryAction, child: Text(secondaryActionLabel!)),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.small),
      child: content,
    );
  }
}
