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
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.titleMedium),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          subtitle!,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.mutedTextFor(context),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (status != null) ...[
                AppStatusBadge(
                  label: status!.name[0].toUpperCase() +
                      status!.name.substring(1),
                  status: status!,
                ),
                const SizedBox(width: AppSpacing.space8),
              ],
              if (amount != null)
                Text(
                  amount!,
                  style: textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
