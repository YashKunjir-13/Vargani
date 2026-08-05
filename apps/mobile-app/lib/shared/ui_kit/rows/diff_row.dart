import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/semantic_colors.dart';

/// A "before -> after" value comparison.
///
/// This is the **one** implementation of the field-comparison pattern used
/// by both the Budget module (revision/approval diffs) and the Audit Log
/// module (field-change comparisons) -- per the approved design system,
/// a budget revision is structurally an audited change, so both must look
/// and behave identically rather than each module inventing its own diff
/// visualization.
class DiffRow extends StatelessWidget {
  final String oldValue;
  final String newValue;

  const DiffRow({super.key, required this.oldValue, required this.newValue});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<SemanticColors>()!;

    return Row(
      children: [
        Expanded(
          child: _ValueBlock(
            value: oldValue,
            background: colorScheme.errorContainer,
            foreground: colorScheme.onErrorContainer,
            strikethrough: true,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space8),
          child: Icon(Icons.arrow_forward, size: AppIconSize.small, color: colorScheme.onSurfaceVariant),
        ),
        Expanded(
          child: _ValueBlock(
            value: newValue,
            background: semantic.successContainer,
            foreground: semantic.onSuccessContainer,
            strikethrough: false,
          ),
        ),
      ],
    );
  }
}

class _ValueBlock extends StatelessWidget {
  final String value;
  final Color background;
  final Color foreground;
  final bool strikethrough;

  const _ValueBlock({
    required this.value,
    required this.background,
    required this.foreground,
    required this.strikethrough,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space12, vertical: AppSpacing.space8),
      decoration: BoxDecoration(
        color: strikethrough ? background.withValues(alpha: 0.8) : background,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Text(
        value,
        style: textTheme.bodyMedium?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
          decoration: strikethrough ? TextDecoration.lineThrough : null,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
