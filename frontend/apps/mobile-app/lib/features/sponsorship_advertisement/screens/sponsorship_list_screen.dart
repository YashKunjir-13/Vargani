import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../shared/shared.dart';
import '../../../shared/widgets/formatters.dart';
import '../models/sponsorship.dart';
import '../providers/sponsorship_providers.dart';
import '../widgets/sponsor_list_item.dart';
import 'sponsorship_detail_screen.dart';
import 'sponsorship_form_screen.dart';

class SponsorshipListScreen extends ConsumerWidget {
  const SponsorshipListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeControllerProvider);
    final sponsorshipsAsync = ref.watch(sponsorshipListProvider);
    final role = ref.watch(roleProvider);

    final canManage = role == UserRole.trustPresident ||
        role == UserRole.vicePresident ||
        role == UserRole.treasurer;

    return AppScaffold(
      title: context.sponsors,
      body: sponsorshipsAsync.when(
        data: (sponsorships) {
          final confirmedTotal = sponsorships
              .where((s) => s.status == SponsorshipStatus.confirmed)
              .fold<int>(0, (sum, s) => sum + s.confirmedAmountPaise);
          final pledgedTotal = sponsorships
              .where((s) => s.status == SponsorshipStatus.pledged)
              .fold<int>(0, (sum, s) => sum + s.pledgedAmountPaise);
          final pendingTotal = sponsorships
              .where((s) => s.status == SponsorshipStatus.pending)
              .fold<int>(0, (sum, s) => sum + s.pledgedAmountPaise);

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(sponsorshipListProvider),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.space24),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppSummaryStatCard(
                        label: context.confirmedLabel,
                        value: formatPaiseAsRupees(confirmedTotal),
                        valueColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? AppColors.darkSuccess
                                : AppColors.lightSuccess,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space8),
                    Expanded(
                      child: AppSummaryStatCard(
                        label: context.pledgedLabel,
                        value: formatPaiseAsRupees(pledgedTotal),
                        valueColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? AppColors.darkWarning
                                : AppColors.lightWarning,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space8),
                    Expanded(
                      child: AppSummaryStatCard(
                        label: context.pendingLabel,
                        value: formatPaiseAsRupees(pendingTotal),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space16),
                AppSearchBar(
                  hint: context.searchSponsorsHint,
                  onChanged: (value) => ref
                      .read(sponsorshipListControllerProvider.notifier)
                      .updateSearch(value),
                ),
                const SizedBox(height: AppSpacing.space16),
                if (canManage)
                  AppButton(
                    label: context.addSponsorBtn,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const SponsorshipFormScreen()),
                    ),
                  ),
                if (canManage) const SizedBox(height: AppSpacing.space16),
                if (sponsorships.isEmpty)
                  const AppEmptyState(
                    title: 'No sponsors found',
                    message: 'Try a different search or add a new sponsor.',
                  )
                else
                  ...sponsorships.map(
                    (sponsorship) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.space8),
                      child: SponsorListItem(
                        sponsorship: sponsorship,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SponsorshipDetailScreen(
                              sponsorshipId: sponsorship.id,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const AppLoadingIndicator(label: 'Loading sponsors...'),
        error: (e, _) => AppErrorView(message: e.toString()),
      ),
    );
  }
}
