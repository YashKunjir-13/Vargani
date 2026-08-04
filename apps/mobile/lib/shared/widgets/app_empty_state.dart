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
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: AppColors.mutedTextFor(context),
            ),
            const SizedBox(height: AppSpacing.space16),
            Text(title, style: textTheme.titleMedium),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.space8),
              Text(
                message!,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedTextFor(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.space24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
