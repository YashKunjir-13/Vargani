import 'package:flutter/material.dart';

import '../../core/core.dart';

class AppSummaryStatCard extends StatelessWidget {
  const AppSummaryStatCard({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedTextFor(context),
              ),
            ),
            const SizedBox(height: AppSpacing.space8),
            Text(
              value,
              style: textTheme.headlineMedium?.copyWith(
                color: valueColor ?? Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
