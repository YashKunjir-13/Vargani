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
                  Row(
                    children: [
                      SponsorshipTierBadge(tier: sponsorship.tier),
                      const SizedBox(width: AppSpacing.sm),
                      SponsorshipStatusBadge(status: sponsorship.status),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    sponsorship.sponsorName,
                    style: AppTypography.titleMedium(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (sponsorship.contactPerson != null &&
                      sponsorship.contactPerson!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Contact: ${sponsorship.contactPerson}',
                      style: AppTypography.caption(
                        context,
                        color: AppColors.mutedTextFor(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatPaiseAsRupees(amountPaise),
                  style: AppTypography.titleLarge(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  sponsorship.status == SponsorshipStatus.confirmed
                      ? 'Confirmed'
                      : 'Pledged',
                  style: AppTypography.caption(
                    context,
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
