import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../../../shared/shared.dart';
import '../../../shared/widgets/formatters.dart';
import '../models/sponsorship.dart';
import 'sponsorship_status_badge.dart';
import 'sponsorship_tier_badge.dart';

class SponsorListItem extends StatelessWidget {
  const SponsorListItem({
    super.key,
    required this.sponsorship,
    required this.onTap,
  });

  final Sponsorship sponsorship;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final amountPaise = sponsorship.status == SponsorshipStatus.confirmed
        ? sponsorship.confirmedAmountPaise
        : sponsorship.pledgedAmountPaise;

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
                  Row(
                    children: [
                      SponsorshipTierBadge(tier: sponsorship.tier),
                      const SizedBox(width: AppSpacing.space8),
                      SponsorshipStatusBadge(status: sponsorship.status),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space8),
                  Text(
                    sponsorship.sponsorName,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (sponsorship.contactPerson != null &&
                      sponsorship.contactPerson!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      'Contact: ${sponsorship.contactPerson}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.mutedTextFor(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.space16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatPaiseAsRupees(amountPaise),
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  sponsorship.status == SponsorshipStatus.confirmed
                      ? 'Confirmed'
                      : 'Pledged',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedTextFor(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
