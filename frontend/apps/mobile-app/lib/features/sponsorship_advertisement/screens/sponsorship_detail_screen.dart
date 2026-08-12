import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../shared/shared.dart';
import '../../../shared/widgets/formatters.dart';
import '../models/sponsorship.dart';
import '../providers/sponsorship_providers.dart';
import '../widgets/sponsorship_status_badge.dart';
import '../widgets/sponsorship_tier_badge.dart';
import 'sponsorship_form_screen.dart';

class SponsorshipDetailScreen extends ConsumerWidget {
  const SponsorshipDetailScreen({super.key, required this.sponsorshipId});

  final String sponsorshipId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sponsorshipAsync =
        ref.watch(sponsorshipDetailProvider(sponsorshipId));
    final role = ref.watch(roleProvider);
    final textTheme = Theme.of(context).textTheme;

    return sponsorshipAsync.when(
      data: (sponsorship) {
        if (sponsorship == null) {
          return const AppScaffold(
            title: 'Sponsorship Detail',
            body: AppEmptyState(title: 'Sponsorship not found'),
          );
        }

        final canViewSensitive = role == UserRole.trustPresident ||
            role == UserRole.vicePresident ||
            role == UserRole.treasurer;

        return AppScaffold(
          title: sponsorship.sponsorName,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.space24),
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
                const SizedBox(height: AppSpacing.space16),
                Text(
                  sponsorship.sponsorName,
                  style: textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.space16),
                AppCard(
                  title: 'Contact Information',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (sponsorship.contactPerson != null &&
                          sponsorship.contactPerson!.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 18),
                            const SizedBox(width: AppSpacing.space8),
                            Text(
                              'Contact: ${sponsorship.contactPerson}',
                              style: textTheme.bodyLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.space8),
                      ],
                      if (sponsorship.mobile != null &&
                          sponsorship.mobile!.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined, size: 18),
                            const SizedBox(width: AppSpacing.space8),
                            Text(
                              'Mobile: ${maskMobile(sponsorship.mobile!, canViewSensitive: canViewSensitive)}',
                              style: textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ],
                      if ((sponsorship.contactPerson == null ||
                              sponsorship.contactPerson!.isEmpty) &&
                          (sponsorship.mobile == null ||
                              sponsorship.mobile!.isEmpty))
                        Text(
                          'No contact details provided.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.mutedTextFor(context),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.space24),
                Row(
                  children: [
                    Expanded(
                      child: AppSummaryStatCard(
                        label: 'Pledged Amount',
                        value:
                            formatPaiseAsRupees(sponsorship.pledgedAmountPaise),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space8),
                    Expanded(
                      child: AppSummaryStatCard(
                        label: 'Confirmed Amount',
                        value: formatPaiseAsRupees(
                            sponsorship.confirmedAmountPaise),
                        valueColor: sponsorship.confirmedAmountPaise > 0
                            ? (Theme.of(context).brightness == Brightness.dark
                                ? AppColors.darkSuccess
                                : AppColors.lightSuccess)
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space32),
                if (sponsorship.status != SponsorshipStatus.confirmed)
                  RoleGate(
                    allowedRoles: const [
                      UserRole.trustPresident,
                      UserRole.vicePresident,
                      UserRole.treasurer,
                    ],
                    child: Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.space16),
                      child: AppButton(
                        label: 'Mark as Confirmed',
                        icon: Icons.check_circle_outline,
                        onPressed: () =>
                            _confirmSponsorship(context, ref, sponsorship),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          floatingActionButton: RoleGate(
            allowedRoles: const [
              UserRole.trustPresident,
              UserRole.vicePresident,
              UserRole.treasurer,
            ],
            child: AppFab(
              label: 'Edit',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SponsorshipFormScreen(
                      sponsorshipId: sponsorship.id,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
      loading: () => const AppScaffold(
        title: 'Sponsorship Detail',
        body: AppLoadingIndicator(label: 'Loading sponsorship...'),
      ),
      error: (error, stack) => AppScaffold(
        title: 'Sponsorship Detail',
        body: AppErrorView(message: error.toString()),
      ),
    );
  }

  void _confirmSponsorship(
    BuildContext context,
    WidgetRef ref,
    Sponsorship sponsorship,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Sponsorship'),
          content: Text(
            'Are you sure you want to mark ${sponsorship.sponsorName} as Confirmed for ${formatPaiseAsRupees(sponsorship.pledgedAmountPaise)}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await ref
                    .read(sponsorshipRepositoryProvider)
                    .markAsConfirmed(sponsorship.id);
                ref.invalidate(sponsorshipListProvider);
                ref.invalidate(sponsorshipDetailProvider(sponsorship.id));
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
