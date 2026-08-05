import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

/// The chrome every bottom sheet in the app shares: a drag handle, a
/// title/subtitle header, a scrollable body, and an optional sticky
/// footer action row.
///
/// Export and Filter sheets across all four modules are built on top of
/// this single shell rather than each hand-rolling its own handle bar and
/// header layout.
class AppBottomSheet extends StatelessWidget {
  final String title;

  /// Header trailing slot -- typically a caption [Text] (e.g. "This Week")
  /// or a "Reset" [TextButton] for filter sheets.
  final Widget? trailing;
  final Widget child;
  final List<Widget>? actions;

  const AppBottomSheet({
    super.key,
    required this.title,
    this.trailing,
    required this.child,
    this.actions,
  });

  /// Presents [builder]'s content inside the standard modal bottom sheet
  /// chrome (scroll-controlled, safe-area aware, transparent barrier so the
  /// sheet's own rounded corners show through).
  static Future<T?> show<T>(BuildContext context, {required WidgetBuilder builder}) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.large)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.space8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space20,
              AppSpacing.space12,
              AppSpacing.space20,
              AppSpacing.space12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: textTheme.titleMedium),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.space20),
              child: child,
            ),
          ),
          if (actions != null) ...[
            Divider(height: 1, color: colorScheme.outlineVariant),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.space16),
              child: Row(
                children: [
                  for (var i = 0; i < actions!.length; i++) ...[
                    if (i > 0) const SizedBox(width: AppSpacing.space8),
                    Expanded(child: actions![i]),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
