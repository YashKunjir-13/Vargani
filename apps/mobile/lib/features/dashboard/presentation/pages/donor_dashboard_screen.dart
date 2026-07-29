import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pauti_pustak_mobile/l10n/app_localizations.dart';
import 'package:pauti_pustak_mobile/core/localization/localization_extensions.dart';
import 'package:pauti_pustak_mobile/core/session/session_controller.dart';
import 'package:pauti_pustak_mobile/core/theme/theme_controller.dart';
import 'package:pauti_pustak_mobile/features/authentication/presentation/widgets/auth_design_tokens.dart';
import 'package:pauti_pustak_mobile/features/authentication/presentation/widgets/language_selector.dart';
import 'package:pauti_pustak_mobile/features/dashboard/data/models/dashboard_models.dart';
import 'package:pauti_pustak_mobile/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:pauti_pustak_mobile/features/dashboard/presentation/widgets/action_sheets.dart';
import 'package:pauti_pustak_mobile/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:pauti_pustak_mobile/features/dashboard/presentation/widgets/quick_actions_bar.dart';
import 'package:pauti_pustak_mobile/features/dashboard/presentation/widgets/summary_card.dart';
import 'package:pauti_pustak_mobile/features/dashboard/presentation/widgets/transaction_list.dart';
import 'package:pauti_pustak_mobile/shared/widgets/app_bottom_nav.dart';

class DonorDashboardScreen extends ConsumerStatefulWidget {
  const DonorDashboardScreen({super.key});

  @override
  ConsumerState<DonorDashboardScreen> createState() => _DonorDashboardScreenState();
}

class _DonorDashboardScreenState extends ConsumerState<DonorDashboardScreen> {
  int _currentIndex = 0;

  String _formatAmount(int paise) {
    final rupees = (paise / 100).floor();
    return '₹${rupees.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.authColors;
    final data = ref.watch(donorDashboardProvider);
    final user = ref.watch(sessionControllerProvider).user;
    final l10n = context.l10n;

    final donorName = user?.donorProfile?.fullName ?? user?.displayName ?? data.donorName;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: DashboardHeader(
        title: l10n.welcomeBack,
        subtitle: donorName,
        badgeText: 'दे',
        onProfileTap: () => setState(() => _currentIndex = 3),
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            // 0: Home Tab
            _buildDonorHomeView(context, data, colors, l10n),

            // 1: History Tab
            _buildDonorHistoryView(context, data, colors, l10n),

            // 2: Digital Receipts Tab
            _buildDonorReceiptsView(context, data, colors, l10n),

            // 3: Profile & Settings Tab
            _buildDonorProfileView(context, data, colors, l10n),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.card,
          border: Border(top: BorderSide(color: colors.border)),
        ),
        child: AppBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            const AppBottomNavItem(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              label: 'Home',
              route: '',
            ),
            const AppBottomNavItem(
              icon: Icons.history_outlined,
              selectedIcon: Icons.history,
              label: 'History',
              route: '',
            ),
            const AppBottomNavItem(
              icon: Icons.receipt_outlined,
              selectedIcon: Icons.receipt,
              label: 'Receipts',
              route: '',
            ),
            AppBottomNavItem(
              icon: Icons.person_outline,
              selectedIcon: Icons.person,
              label: l10n.profile,
              route: '',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonorHomeView(
    BuildContext context,
    DonorDashboardData data,
    AuthColors colors,
    AppLocalizations l10n,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Contribution Hero Card
          HeroOverviewCard(
            tagline: 'YOUR CONTRIBUTION OVERVIEW',
            mainAmount: _formatAmount(data.totalDonationsPaise),
            subtitle: 'Lifetime donations across registered trusts',
            stat1Label: l10n.thisYear,
            stat1Value: _formatAmount(data.thisYearDonationsPaise),
            stat2Label: l10n.lastDonation,
            stat2Value: _formatAmount(data.lastDonationAmountPaise),
            stat3Label: 'Receipts',
            stat3Value: '${data.digitalReceiptsCount}',
            onTap: () {},
          ),

          const SizedBox(height: 20),

          // Quick Summary Cards Carousel
          Text(
            'KEY HIGHLIGHTS',
            style: TextStyle(
              color: colors.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(
                  width: 170,
                  child: GlassStatCard(
                    title: l10n.totalDonations,
                    value: _formatAmount(data.totalDonationsPaise),
                    icon: Icons.volunteer_activism_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 170,
                  child: GlassStatCard(
                    title: l10n.thisYear,
                    value: _formatAmount(data.thisYearDonationsPaise),
                    icon: Icons.calendar_today_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 170,
                  child: GlassStatCard(
                    title: l10n.favoriteMandal,
                    value: 'SSGM',
                    subtitle: data.favoriteMandalName,
                    icon: Icons.favorite_outline,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 170,
                  child: GlassStatCard(
                    title: l10n.digitalReceipts,
                    value: '${data.digitalReceiptsCount} PDF Receipts',
                    icon: Icons.receipt_long_outlined,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quick Actions Bar
          Text(
            l10n.quickActions,
            style: TextStyle(
              color: colors.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          QuickActionsGrid(
            actions: [
              QuickActionButtonItem(id: 'donate', label: l10n.donateAgain, icon: Icons.volunteer_activism, primary: true),
              QuickActionButtonItem(id: 'view_receipts', label: l10n.viewReceipts, icon: Icons.receipt_long),
              QuickActionButtonItem(id: 'history', label: l10n.contributionHistory, icon: Icons.history),
              QuickActionButtonItem(id: 'campaigns', label: l10n.supportCampaigns, icon: Icons.campaign),
              QuickActionButtonItem(id: 'favs', label: l10n.favouriteMandals, icon: Icons.star_border),
              QuickActionButtonItem(id: 'download', label: l10n.downloadReceiptPdf, icon: Icons.download),
            ],
            onActionTap: (action) {
              if (action.id == 'donate') {
                DashboardActionSheets.showCollectDonationSheet(context);
              } else if (action.id == 'view_receipts' || action.id == 'download') {
                setState(() => _currentIndex = 2);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Action ${action.label} selected.'),
                    backgroundColor: colors.brandOrange,
                  ),
                );
              }
            },
          ),

          const SizedBox(height: 24),

          // Recent Donations Feed
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.recentDonations,
                style: TextStyle(
                  color: colors.secondaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _currentIndex = 1),
                child: Text('View History', style: TextStyle(color: colors.brandOrange, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...data.recentDonations.map((tx) {
            return TransactionListItem(
              item: tx,
              onTap: () {
                DashboardActionSheets.showReceiptDetailModal(
                  context,
                  tx.receiptNumber,
                  tx.donorName,
                  _formatAmount(tx.amountPaise),
                );
              },
            );
          }),

          const SizedBox(height: 24),

          // Analytics Section
          Text(
            l10n.analytics,
            style: TextStyle(
              color: colors.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          _buildDonorAnalyticsChart(context, data, colors, l10n),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDonorAnalyticsChart(
    BuildContext context,
    DonorDashboardData data,
    AuthColors colors,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.donationHistoryGraph,
            style: TextStyle(
              color: colors.text,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          ...data.yearlyBreakdown.entries.map((entry) {
            final year = entry.key;
            final amount = entry.value;
            final percentage = (amount / 5000000).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$year Contribution', style: TextStyle(color: colors.text, fontWeight: FontWeight.w800, fontSize: 13)),
                      Text(_formatAmount(amount), style: TextStyle(color: colors.brandOrange, fontWeight: FontWeight.w900, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: percentage,
                      minHeight: 8,
                      backgroundColor: colors.surfaceMuted,
                      valueColor: AlwaysStoppedAnimation<Color>(colors.brandOrange),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDonorHistoryView(BuildContext context, DonorDashboardData data, AuthColors colors, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.contributionHistory, style: TextStyle(color: colors.text, fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 16),
        ...data.recentDonations.map((tx) => TransactionListItem(item: tx)),
      ],
    );
  }

  Widget _buildDonorReceiptsView(BuildContext context, DonorDashboardData data, AuthColors colors, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.digitalReceipts, style: TextStyle(color: colors.text, fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 16),
        ...data.recentDonations.map((tx) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 32),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Receipt ${tx.receiptNumber}', style: TextStyle(color: colors.text, fontWeight: FontWeight.w800, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(tx.mandalName ?? 'Ganpati Mandal', style: TextStyle(color: colors.secondaryText, fontSize: 13)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.brandOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    DashboardActionSheets.showReceiptDetailModal(
                      context,
                      tx.receiptNumber,
                      tx.donorName,
                      _formatAmount(tx.amountPaise),
                    );
                  },
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('PDF'),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDonorProfileView(
    BuildContext context,
    DonorDashboardData data,
    AuthColors colors,
    AppLocalizations l10n,
  ) {
    final user = ref.watch(sessionControllerProvider).user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: colors.gold,
                child: const Icon(Icons.person, color: Colors.white, size: 44),
              ),
              const SizedBox(height: 12),
              Text(
                user?.donorProfile?.fullName ?? user?.displayName ?? data.donorName,
                style: TextStyle(color: colors.text, fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                '+91 ${user?.primaryMobile ?? data.mobile} • ${user?.primaryEmail ?? data.email}',
                style: TextStyle(color: colors.secondaryText, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ListTile(
          leading: Icon(Icons.edit_outlined, color: colors.brandOrange),
          title: Text(l10n.editProfile, style: TextStyle(color: colors.text, fontWeight: FontWeight.w700)),
          trailing: Icon(Icons.chevron_right, color: colors.secondaryText),
          onTap: () {},
        ),
        const Divider(),
        ListTile(
          leading: Icon(Icons.language, color: colors.brandOrange),
          title: Text(l10n.selectLanguage, style: TextStyle(color: colors.text, fontWeight: FontWeight.w700)),
          trailing: const AuthLanguageSelector(),
        ),
        const Divider(),
        SwitchListTile(
          secondary: Icon(Icons.dark_mode_outlined, color: colors.brandOrange),
          title: Text(l10n.darkMode, style: TextStyle(color: colors.text, fontWeight: FontWeight.w700)),
          value: isDark,
          onChanged: (val) {
            ref.read(themeControllerProvider.notifier).toggleTheme(val);
          },
        ),
        const Divider(),
        ListTile(
          leading: Icon(Icons.notifications_outlined, color: colors.brandOrange),
          title: Text(l10n.notifications, style: TextStyle(color: colors.text, fontWeight: FontWeight.w700)),
          trailing: Icon(Icons.chevron_right, color: colors.secondaryText),
          onTap: () {},
        ),
        const Divider(),
        ListTile(
          leading: Icon(Icons.privacy_tip_outlined, color: colors.brandOrange),
          title: Text(l10n.privacy, style: TextStyle(color: colors.text, fontWeight: FontWeight.w700)),
          trailing: Icon(Icons.chevron_right, color: colors.secondaryText),
          onTap: () {},
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: Text(l10n.logout, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w800)),
          onTap: () {
            ref.read(sessionControllerProvider.notifier).logout();
          },
        ),
      ],
    );
  }
}
