import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../models/app_status.dart';
import 'app_status_badge.dart';

class AppListItemCard extends StatelessWidget {
  const AppListItemCard({
    super.key,
    required this.title,
    this.subtitle,
    this.amount,
    this.status,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final String? amount;
  final AppStatus? status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.titleMedium(context)),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(subtitle!, style: AppTypography.caption(context, color: AppColors.mutedTextFor(context))),
                      ),
                  ],
                ),
              ),
              if (status != null) ...[
                AppStatusBadge(label: status!.name[0].toUpperCase() + status!.name.substring(1), status: status!),
                const SizedBox(width: AppSpacing.sm),
              ],
              if (amount != null)
                Text(amount!, style: AppTypography.titleMedium(context, color: Theme.of(context).colorScheme.primary)),
            ],
          ),
        ),
      ),
    );
  }
}
