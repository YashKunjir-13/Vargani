import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../models/app_status.dart';

class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({super.key, required this.label, required this.status});

  final String label;
  final AppStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      AppStatus.success => AppColors.lightSuccess,
      AppStatus.pending => AppColors.lightPending,
      AppStatus.warning => AppColors.lightWarning,
      AppStatus.error => AppColors.lightError,
      AppStatus.info => AppColors.lightInfo,
      AppStatus.neutral => AppColors.lightNeutral,
    };

    final textColor = Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.onSurface
        : color;
    final backgroundColor = Theme.of(context).brightness == Brightness.dark
        ? color.withValues(alpha: 0.2)
        : color.withValues(alpha: 0.12);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: textColor,
              fontSize: 11,
            ),
      ),
    );
  }
}
