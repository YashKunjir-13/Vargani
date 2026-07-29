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
import 'package:pauti_pustak_mobile/features/dashboard/presentation/widgets/analytics_charts.dart';
import 'package:pauti_pustak_mobile/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:pauti_pustak_mobile/features/dashboard/presentation/widgets/module_grid.dart';
import 'package:pauti_pustak_mobile/features/dashboard/presentation/widgets/quick_actions_bar.dart';
import 'package:pauti_pustak_mobile/features/dashboard/presentation/widgets/summary_card.dart';
import 'package:pauti_pustak_mobile/features/dashboard/presentation/widgets/transaction_list.dart';

class MandalDashboardScreen extends ConsumerStatefulWidget {
  const MandalDashboardScreen({super.key});

  @override
  ConsumerState<MandalDashboardScreen> createState() => _MandalDashboardScreenState();
}

class _MandalDashboardScreenState extends ConsumerState<MandalDashboardScreen> {
  int _currentIndex = 0;

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    final l10n = context.l10n;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 17) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  String _formatAmount(int paise) {
    final rupees = (paise / 100).floor();
    return '₹${rupees.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.authColors;
    final data = ref.watch(mandalDashboardProvider);
    final user = ref.watch(sessionControllerProvider).user;
    final l10n = context.l10n;

    final mandalName = user?.organization?.name ?? data.mandalName;
    final greeting = _getGreeting(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: DashboardHeader(
        title: '$greeting,',
        subtitle: mandalName,
        badgeText: 'पप',
        onProfileTap: () => setState(() => _currentIndex = 4),
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            // 0: Dashboard (Main Home View)
            _buildMainDashboardView(context, data, colors, l10n),

            // 1: Contributions Tab
            _buildContributionsView(context, data, colors),

            // 2: Bills Tab
            _buildBillsView(context, data, colors),

            // 3: Reports Tab
            _buildReportsView(context, data, colors),

            // 4: Profile & Settings Tab
            _buildMandalProfileView(context, data, colors, l10n),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.card,
          border: Border(top: BorderSide(color: colors.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: colors.card,
          selectedItemColor: colors.brandOrange,
          unselectedItemColor: colors.secondaryText,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_outlined),
              activeIcon: const Icon(Icons.dashboard),
              label: l10n.mandalDashboardTitle.split(' ').first,
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.monetization_on_outlined),
              activeIcon: Icon(Icons.monetization_on),
              label: 'Contributions',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined),
              activeIcon: Icon(Icons.description),
              label: 'Bills',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.assessment_outlined),
              activeIcon: Icon(Icons.assessment),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: l10n.profile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainDashboardView(
    BuildContext context,
    MandalDashboardData data,
    AuthColors colors,
    AppLocalizations l10n,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero overview banner card
          HeroOverviewCard(
            tagline: l10n.festivalOverview,
            mainAmount: _formatAmount(data.totalCollectionPaise),
            subtitle: 'Total collections • ${data.festivalYear}',
            stat1Label: 'Expenses',
            stat1Value: '₹1.15K',
            stat2Label: 'Balance',
            stat2Value: '₹3.67K',
            stat3Label: 'Donors',
            stat3Value: '${data.totalDonorsCount}',
            onTap: () {},
          ),

          const SizedBox(height: 20),

          // Quick Summary Cards Row
          Text(
            'QUICK SUMMARY',
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
                    title: l10n.currentBalance,
                    value: _formatAmount(data.currentBalancePaise),
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 170,
                  child: GlassStatCard(
                    title: l10n.todaysCollection,
                    value: _formatAmount(data.todaysCollectionPaise),
                    icon: Icons.today_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 170,
                  child: GlassStatCard(
                    title: l10n.pendingBills,
                    value: '${data.pendingBillsCount} Bills',
                    icon: Icons.description_outlined,
                    badgeText: '${data.pendingBillsCount}',
                    badgeColor: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 170,
                  child: GlassStatCard(
                    title: l10n.pendingReceipts,
                    value: '${data.pendingReceiptsCount} Receipts',
                    icon: Icons.receipt_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 170,
                  child: GlassStatCard(
                    title: l10n.volunteersCount,
                    value: '${data.activeVolunteersCount} Active',
                    icon: Icons.groups_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 170,
                  child: GlassStatCard(
                    title: l10n.totalDonors,
                    value: '${data.totalDonorsCount}',
                    icon: Icons.person_search_outlined,
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
              QuickActionButtonItem(id: 'collect', label: l10n.collectDonation, icon: Icons.add_card, primary: true),
              QuickActionButtonItem(id: 'receipt', label: l10n.generateReceipt, icon: Icons.receipt_long),
              QuickActionButtonItem(id: 'expense', label: l10n.addExpense, icon: Icons.attach_money),
              QuickActionButtonItem(id: 'bill', label: l10n.createBill, icon: Icons.post_add),
              QuickActionButtonItem(id: 'volunteer', label: l10n.addVolunteer, icon: Icons.person_add_alt),
              QuickActionButtonItem(id: 'sponsor', label: l10n.addSponsor, icon: Icons.card_membership),
              QuickActionButtonItem(id: 'reports', label: l10n.viewReports, icon: Icons.bar_chart),
            ],
            onActionTap: (action) {
              if (action.id == 'collect' || action.id == 'receipt') {
                DashboardActionSheets.showCollectDonationSheet(context);
              } else if (action.id == 'expense' || action.id == 'bill') {
                DashboardActionSheets.showAddExpenseSheet(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Action: ${action.label} opened.'),
                    backgroundColor: colors.brandOrange,
                  ),
                );
              }
            },
          ),

          const SizedBox(height: 24),

          // Main Modules Section (15 Modules)
          Text(
            l10n.mainModules,
            style: TextStyle(
              color: colors.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          MandalModuleGrid(
            modules: data.modules,
            onModuleTap: (module) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Module ${module.title} opened.'),
                  backgroundColor: colors.brandOrange,
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Recent Transactions Feed
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.recentTransactions,
                style: TextStyle(
                  color: colors.secondaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _currentIndex = 1),
                child: Text(
                  'View All',
                  style: TextStyle(color: colors.brandOrange, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...data.transactions.map((tx) {
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
          IncomeVsExpenseCard(
            incomePaise: data.totalCollectionPaise,
            expensePaise: data.totalExpensesPaise,
          ),
          const SizedBox(height: 16),
          TopDonorsWidget(topDonors: data.topDonors),
          const SizedBox(height: 16),
          BudgetUtilizationWidget(budgets: data.budgets),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildContributionsView(BuildContext context, MandalDashboardData data, AuthColors colors) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'All Contributions & Receipts',
          style: TextStyle(color: colors.text, fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 16),
        ...data.transactions.map((tx) => TransactionListItem(item: tx)),
      ],
    );
  }

  Widget _buildBillsView(BuildContext context, MandalDashboardData data, AuthColors colors) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Pending Vendor Bills & Invoices',
          style: TextStyle(color: colors.text, fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 16),
        ...data.pendingPayments.map((p) {
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
                Icon(Icons.inventory_2_outlined, color: colors.brandOrange, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.vendorName, style: TextStyle(color: colors.text, fontWeight: FontWeight.w800, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(p.description, style: TextStyle(color: colors.secondaryText, fontSize: 13)),
                    ],
                  ),
                ),
                Text(
                  _formatAmount(p.amountPaise),
                  style: TextStyle(color: colors.brandOrange, fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildReportsView(BuildContext context, MandalDashboardData data, AuthColors colors) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        IncomeVsExpenseCard(incomePaise: data.totalCollectionPaise, expensePaise: data.totalExpensesPaise),
        const SizedBox(height: 16),
        TopDonorsWidget(topDonors: data.topDonors),
        const SizedBox(height: 16),
        BudgetUtilizationWidget(budgets: data.budgets),
      ],
    );
  }

  Widget _buildMandalProfileView(
    BuildContext context,
    MandalDashboardData data,
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
                backgroundColor: colors.brandOrange,
                child: const Text('पप', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(height: 12),
              Text(
                user?.displayName ?? data.mandalName,
                style: TextStyle(color: colors.text, fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                'Trustee / Mandal Owner • +91 ${user?.primaryMobile ?? '9876543210'}',
                style: TextStyle(color: colors.secondaryText, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
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
