import 'package:flutter/material.dart';

import '../../core/core.dart';

class AppSummaryStatCard extends StatelessWidget {
  const AppSummaryStatCard({super.key, required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.caption(context, color: AppColors.mutedTextFor(context))),
            const SizedBox(height: AppSpacing.sm),
            Text(value, style: AppTypography.display(context, color: valueColor ?? Theme.of(context).colorScheme.primary)),
          ],
        ),
      ),
    );
  }
}
