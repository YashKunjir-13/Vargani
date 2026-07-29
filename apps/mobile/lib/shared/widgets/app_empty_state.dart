import 'package:flutter/material.dart';

import '../../core/core.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState(
      {super.key, required this.title, this.message, this.action});

  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined,
                size: 48, color: AppColors.mutedTextFor(context)),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: AppTypography.titleMedium(context)),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(message!,
                  style: AppTypography.caption(context,
                      color: AppColors.mutedTextFor(context)),
                  textAlign: TextAlign.center),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
