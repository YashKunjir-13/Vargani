import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../shared/shared.dart';
import '../../../shared/widgets/formatters.dart';
import '../models/sponsorship.dart';
import '../providers/advertisement_providers.dart';
import '../providers/sponsorship_providers.dart';
import '../widgets/advertisement_list_item.dart';
import '../widgets/sponsor_list_item.dart';
import 'advertisement_detail_screen.dart';
import 'advertisement_form_screen.dart';
import 'sponsorship_detail_screen.dart';
import 'sponsorship_form_screen.dart';

class SponsorshipAdvertisementScreen extends ConsumerStatefulWidget {
  const SponsorshipAdvertisementScreen({super.key});

  @override
  ConsumerState<SponsorshipAdvertisementScreen> createState() =>
      _SponsorshipAdvertisementScreenState();
}

class _SponsorshipAdvertisementScreenState
    extends ConsumerState<SponsorshipAdvertisementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final initialTab = ref.read(selectedSponsorshipTabProvider);
    _tabController = TabController(length: 2, vsync: this, initialIndex: initialTab);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(selectedSponsorshipTabProvider.notifier).state =
            _tabController.index;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Sponsorship',
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.borderFor(context),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Theme.of(context).colorScheme.primary,
              indicatorWeight: 3,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: AppColors.mutedTextFor(context),
              labelStyle: AppTypography.titleMedium(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: AppTypography.titleMedium(context),
              tabs: const [
                Tab(text: 'Sponsors'),
                Tab(text: 'Advertisements'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSponsorsTab(context),
                _buildAdvertisementsTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSponsorsTab(BuildContext context) {
    final sponsorshipsAsync = ref.watch(sponsorshipListProvider);

    return sponsorshipsAsync.when(
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
          onRefresh: () async {
            ref.invalidate(sponsorshipListProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTintedStatCard(
                        context: context,
                        label: 'Confirmed',
                        value: formatPaiseAsRupees(confirmedTotal),
                        lightBg: const Color(0xFFE8F5E9), // Soft green tint
                        darkBg: const Color(0xFF064E3B).withValues(alpha: 0.35),
                        textColor: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkSuccess
                            : AppColors.lightSuccess,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _buildTintedStatCard(
                        context: context,
                        label: 'Pledged',
                        value: formatPaiseAsRupees(pledgedTotal),
                        lightBg: const Color(0xFFFFF3E0), // Soft orange tint
                        darkBg: const Color(0xFF78350F).withValues(alpha: 0.35),
                        textColor: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkWarning
                            : AppColors.lightWarning,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _buildTintedStatCard(
                        context: context,
                        label: 'Pending',
                        value: formatPaiseAsRupees(pendingTotal),
                        lightBg: const Color(0xFFE3F2FD), // Soft blue tint
                        darkBg: const Color(0xFF1E3A8A).withValues(alpha: 0.35),
                        textColor: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkInfo
                            : AppColors.lightInfo,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                RoleGate(
                  allowedRoles: const [Role.owner, Role.president, Role.treasurer],
                  child: AppButton(
                    label: '+ Add Sponsor',
                    icon: Icons.add,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SponsorshipFormScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (sponsorships.isEmpty)
                  const AppEmptyState(
                    title: 'No sponsors found',
                    message: 'Click + Add Sponsor to record a sponsorship.',
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sponsorships.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final sponsorship = sponsorships[index];
                      return SponsorListItem(
                        sponsorship: sponsorship,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SponsorshipDetailScreen(
                                sponsorshipId: sponsorship.id,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => const AppLoadingIndicator(label: 'Loading sponsors...'),
      error: (error, stack) => AppErrorView(message: error.toString()),
    );
  }

  Widget _buildAdvertisementsTab(BuildContext context) {
    final advertisementsAsync = ref.watch(advertisementListProvider);

    return advertisementsAsync.when(
      data: (ads) {
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(advertisementListProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RoleGate(
                  allowedRoles: const [Role.owner, Role.president, Role.treasurer],
                  child: AppButton(
                    label: '+ Book Advertisement',
                    icon: Icons.add,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AdvertisementFormScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (ads.isEmpty)
                  const AppEmptyState(
                    title: 'No advertisements booked',
                    message: 'Click + Book Advertisement to add a new placement.',
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ads.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final ad = ads[index];
                      return AdvertisementListItem(
                        advertisement: ad,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AdvertisementDetailScreen(
                                advertisementId: ad.id,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => const AppLoadingIndicator(label: 'Loading advertisements...'),
      error: (error, stack) => AppErrorView(message: error.toString()),
    );
  }

  Widget _buildTintedStatCard({
    required BuildContext context,
    required String label,
    required String value,
    required Color lightBg,
    required Color darkBg,
    required Color textColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? darkBg : lightBg;
    final borderColor = textColor.withValues(alpha: isDark ? 0.35 : 0.25);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption(
              context,
              color: AppColors.mutedTextFor(context),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTypography.titleLarge(context).copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
