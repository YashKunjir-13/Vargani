import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../../../shared/shared.dart';
import '../../../shared/widgets/formatters.dart';
import '../models/advertisement.dart';
import 'advertisement_status_badge.dart';

class AdvertisementListItem extends StatelessWidget {
  const AdvertisementListItem({
    super.key,
    required this.advertisement,
    required this.onTap,
  });

  final Advertisement advertisement;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    advertisement.advertiserName,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (advertisement.placementDetail != null &&
                      advertisement.placementDetail!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      advertisement.placementDetail!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.mutedTextFor(context),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.space8),
                  AdvertisementStatusBadge(status: advertisement.status),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.space16),
            Text(
              formatPaiseAsRupees(advertisement.amountPaise),
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
