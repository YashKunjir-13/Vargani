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
    return AppCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    advertisement.advertiserName,
                    style: AppTypography.titleMedium(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (advertisement.placementDetail != null &&
                      advertisement.placementDetail!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      advertisement.placementDetail!,
                      style: AppTypography.caption(
                        context,
                        color: AppColors.mutedTextFor(context),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  AdvertisementStatusBadge(status: advertisement.status),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              formatPaiseAsRupees(advertisement.amountPaise),
              style: AppTypography.titleLarge(context).copyWith(
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
