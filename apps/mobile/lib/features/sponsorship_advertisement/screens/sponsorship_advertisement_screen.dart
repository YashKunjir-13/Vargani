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
  /// [initialTab]: 0 = Sponsors (default), 1 = Advertisements
  const SponsorshipAdvertisementScreen({super.key, this.initialTab = 0});

  final int initialTab;

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
    final savedTab = ref.read(selectedSponsorshipTabProvider);
    final startTab = widget.initialTab != 0 ? widget.initialTab : savedTab;
    _tabController = TabController(length: 2, vsync: this, initialIndex: startTab);
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
    final textTheme = Theme.of(context).textTheme;

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
              labelStyle: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: textTheme.titleMedium,
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
            padding: const EdgeInsets.all(AppSpacing.space24),
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
                        lightBg: const Color(0xFFE8F5E9),
                        darkBg: const Color(0xFF064E3B).withValues(alpha: 0.35),
                        textColor: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkSuccess
                            : AppColors.lightSuccess,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space8),
                    Expanded(
                      child: _buildTintedStatCard(
                        context: context,
                        label: 'Pledged',
                        value: formatPaiseAsRupees(pledgedTotal),
                        lightBg: const Color(0xFFFFF3E0),
                        darkBg: const Color(0xFF78350F).withValues(alpha: 0.35),
                        textColor: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkWarning
                            : AppColors.lightWarning,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space8),
                    Expanded(
                      child: _buildTintedStatCard(
                        context: context,
                        label: 'Pending',
                        value: formatPaiseAsRupees(pendingTotal),
                        lightBg: const Color(0xFFE3F2FD),
                        darkBg: const Color(0xFF1E3A8A).withValues(alpha: 0.35),
                        textColor: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkInfo
                            : AppColors.lightInfo,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space16),
                AppSearchBar(
                  hint: 'Search sponsors',
                  onChanged: (value) => ref
                      .read(sponsorshipListControllerProvider.notifier)
                      .updateSearch(value),
                ),
                const SizedBox(height: AppSpacing.space16),
                RoleGate(
                  allowedRoles: const [
                    UserRole.trustPresident,
                    UserRole.vicePresident,
                    UserRole.treasurer,
                  ],
                  child: AppButton(
                    label: 'Add Sponsor',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SponsorshipFormScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.space16),
                if (sponsorships.isEmpty)
                  const AppEmptyState(
                    title: 'No sponsors found',
                    message: 'Try a different search or add a new sponsor.',
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sponsorships.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.space8),
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
            padding: const EdgeInsets.all(AppSpacing.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSearchBar(
                  hint: 'Search advertisements',
                  onChanged: (value) => ref
                      .read(advertisementListControllerProvider.notifier)
                      .updateSearch(value),
                ),
                const SizedBox(height: AppSpacing.space16),
                RoleGate(
                  allowedRoles: const [
                    UserRole.trustPresident,
                    UserRole.vicePresident,
                    UserRole.treasurer,
                  ],
                  child: AppButton(
                    label: 'Book Advertisement',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AdvertisementFormScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.space16),
                if (ads.isEmpty)
                  const AppEmptyState(
                    title: 'No advertisements booked',
                    message: 'Try a different search or book a new placement.',
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ads.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.space8),
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
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space16,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.mutedTextFor(context),
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: textTheme.titleLarge?.copyWith(
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
