import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pauti_pustak_mobile/l10n/app_localizations.dart';
import 'package:pauti_pustak_mobile/core/localization/localization_extensions.dart';
import 'package:pauti_pustak_mobile/core/session/session_controller.dart';
import 'package:pauti_pustak_mobile/core/theme/app_theme.dart';
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
import 'package:pauti_pustak_mobile/features/volunteers/screens/volunteer_list_screen.dart';
import 'package:pauti_pustak_mobile/features/volunteers/screens/volunteer_form_screen.dart';
import 'package:pauti_pustak_mobile/features/sponsorship_advertisement/screens/sponsorship_list_screen.dart';
import 'package:pauti_pustak_mobile/features/sponsorship_advertisement/screens/sponsorship_form_screen.dart';
import 'package:pauti_pustak_mobile/features/sponsorship_advertisement/screens/advertisement_list_screen.dart';
import 'package:pauti_pustak_mobile/features/profile/widgets/bank_details_section.dart';
import 'package:pauti_pustak_mobile/app/all_records_screen.dart';
import 'package:pauti_pustak_mobile/features/rbac/presentation/providers/mock_rbac_provider.dart';
import 'package:pauti_pustak_mobile/features/rbac/presentation/pages/user_management_screen.dart';
import 'package:pauti_pustak_mobile/shared/widgets/app_bottom_nav.dart';

class MandalDashboardScreen extends ConsumerStatefulWidget {
  const MandalDashboardScreen({super.key});

  @override
  ConsumerState<MandalDashboardScreen> createState() => _MandalDashboardScreenState();
}

class _MandalDashboardScreenState extends ConsumerState<MandalDashboardScreen> {
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

  String _getAllRecordsLabel(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    switch (code) {
      case 'hi':
        return 'सभी रिकॉर्ड';
      case 'mr':
        return 'सर्व नोंदी';
      default:
        return 'All Records';
    }
  }

  String _getAllRecordsSubtitle(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    switch (code) {
      case 'hi':
        return 'सभी श्रेणी रिकॉर्ड ब्राउज़ करें';
      case 'mr':
        return 'सर्व वर्गवारी नोंदी पहा';
      default:
        return 'Browse all category records';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.authColors;
    final data = ref.watch(mandalDashboardProvider);
    final user = ref.watch(sessionControllerProvider).user;
    final l10n = context.l10n;

    final mandalName = user?.organization?.name ?? data.mandalName;
    final greeting = _getGreeting(context);

    final currentIndex = ref.watch(dashboardTabProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: DashboardHeader(
        title: '$greeting,',
        subtitle: mandalName,
        badgeText: 'पप',
        onProfileTap: () => ref.read(dashboardTabProvider.notifier).setTab(4),
      ),
      body: SafeArea(
        child: IndexedStack(
          index: currentIndex,
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
        child: AppBottomNav(
          currentIndex: currentIndex,
          onTap: (index) => ref.read(dashboardTabProvider.notifier).setTab(index),
          items: [
            AppBottomNavItem(
              icon: Icons.dashboard_outlined,
              selectedIcon: Icons.dashboard,
              label: l10n.homeTab,
              route: '',
            ),
            AppBottomNavItem(
              icon: Icons.monetization_on_outlined,
              selectedIcon: Icons.monetization_on,
              label: l10n.contributionsTab,
              route: '',
            ),
            AppBottomNavItem(
              icon: Icons.description_outlined,
              selectedIcon: Icons.description,
              label: l10n.billsTab,
              route: '',
            ),
            AppBottomNavItem(
              icon: Icons.assessment_outlined,
              selectedIcon: Icons.assessment,
              label: l10n.reportsTab,
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

  Widget _buildMainDashboardView(
    BuildContext context,
    MandalDashboardData data,
    AuthColors colors,
    AppLocalizations l10n,
  ) {
    final rbacState = ref.watch(mockRbacProvider);
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
            stat1Value: _formatAmount(data.totalExpensesPaise),
            stat2Label: 'Balance',
            stat2Value: _formatAmount(data.currentBalancePaise),
            stat3Label: 'Donors',
            stat3Value: '${data.totalDonorsCount}',
            onTap: () {},
          ),

          const SizedBox(height: 20),

          // Quick Summary Cards Row
          Text(
            l10n.quickSummarySection,
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
              QuickActionButtonItem(id: 'records', label: _getAllRecordsLabel(context), icon: Icons.folder_open),
              QuickActionButtonItem(id: 'receipt', label: l10n.generateReceipt, icon: Icons.receipt_long),
              QuickActionButtonItem(id: 'expense', label: l10n.addExpense, icon: Icons.attach_money),
              QuickActionButtonItem(id: 'bill', label: l10n.createBill, icon: Icons.post_add),
              QuickActionButtonItem(id: 'volunteer', label: l10n.addVolunteer, icon: Icons.person_add_alt),
              QuickActionButtonItem(id: 'sponsor', label: l10n.addSponsor, icon: Icons.card_membership),
              QuickActionButtonItem(id: 'reports', label: l10n.viewReports, icon: Icons.bar_chart),
            ],
            onActionTap: (action) {
              if (action.id == 'records') {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AllRecordsScreen()));
              } else if (action.id == 'collect' || action.id == 'receipt') {
                context.push('/donation/select-event');
              } else if (action.id == 'expense' || action.id == 'bill') {
                DashboardActionSheets.showAddExpenseSheet(context);
              } else if (action.id == 'volunteer') {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VolunteerFormScreen()));
              } else if (action.id == 'sponsor') {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SponsorshipFormScreen()));
              } else if (action.id == 'reports') {
                ref.read(dashboardTabProvider.notifier).setTab(3);
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
            modules: data.modules.where((m) {
              switch (m.id) {
                case 'contributions':
                  return rbacState.hasPermission('contribution.view');
                case 'collection':
                  return rbacState.hasPermission('donation_collection.view');
                case 'receipts':
                  return rbacState.hasPermission('receipt.view');
                case 'budget':
                  return rbacState.hasPermission('budget.view');
                case 'bills':
                  return rbacState.hasPermission('bill.view');
                case 'vendor_payments':
                  return rbacState.hasPermission('vendor_payment.view');
                case 'kunda':
                  return rbacState.hasPermission('donation_box.view');
                case 'sponsors':
                  return rbacState.hasPermission('sponsor.view');
                case 'advertisements':
                  return rbacState.hasPermission('advertisement.view');
                case 'volunteers':
                  return rbacState.hasPermission('volunteer.view');
                case 'members':
                  return rbacState.hasPermission('member.view');
                case 'reports':
                  return rbacState.hasPermission('reports.view');
                case 'audit':
                  return rbacState.hasPermission('audit_logs.view');
                case 'analytics':
                  return rbacState.hasPermission('analytics.view');
                case 'milestones':
                  return rbacState.hasPermission('milestones.view');
                case 'user_management':
                  return rbacState.hasPermission('user.manage');
                case 'all_records':
                  return rbacState.hasPermission('records.view');
                default:
                  return false;
              }
            }).map((m) {
              if (m.id == 'all_records') {
                return MandalModuleItem(
                  id: 'all_records',
                  title: _getAllRecordsLabel(context),
                  subtitle: _getAllRecordsSubtitle(context),
                  icon: Icons.folder_open_outlined,
                );
              }
              return m;
            }).toList(),
            onModuleTap: (module) {
              switch (module.id) {
                case 'contributions':
                  context.push('/contributions');
                  break;
                case 'collection':
                  context.push('/payments');
                  break;
                case 'receipts':
                  context.push('/receipts');
                  break;
                case 'budget':
                  context.push('/budget');
                  break;
                case 'bills':
                  context.push('/bills');
                  break;
                case 'vendor_payments':
                  context.push('/vendors');
                  break;
                case 'sponsors':
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SponsorshipListScreen()));
                  break;
                case 'advertisements':
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdvertisementListScreen()));
                  break;
                case 'volunteers':
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VolunteerListScreen()));
                  break;
                case 'members':
                  context.push('/user-management');
                  break;
                case 'kunda':
                  context.push('/vault');
                  break;
                case 'reports':
                  context.push('/reports-hub');
                  break;
                case 'audit':
                  context.push('/audit');
                  break;
                case 'analytics':
                  context.push('/analytics');
                  break;
                case 'milestones':
                  context.push('/milestones');
                  break;
                case 'all_records':
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AllRecordsScreen()));
                  break;
                default:
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AllRecordsScreen()));
                  break;
              }
            },
          ),

          const SizedBox(height: 24),

          // Recent Transactions Feed
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  l10n.recentTransactions,
                  style: TextStyle(
                    color: colors.secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () => ref.read(dashboardTabProvider.notifier).setTab(1),
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
        ElevatedButton.icon(
          onPressed: () => context.push('/reports-hub'),
          icon: const Icon(Icons.verified_user),
          label: const Text('Open Full Reports & Audit Hub →'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: colors.brandOrange,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
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
        const SizedBox(height: 24),
        const BankDetailsSection(),
        const SizedBox(height: 24),
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
            ref.read(appThemeModeProvider.notifier).setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
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
        const SizedBox(height: 32),
        // Mock RBAC Persona Switcher for Development / QA Testing
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.brandOrange.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Development Mode: Persona Switcher',
                    style: TextStyle(
                      color: colors.text,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  if (ref.watch(mockRbacProvider).isSuperAdmin)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.brandOrange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'SUPER ADMIN',
                        style: TextStyle(
                          color: colors.brandOrange,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Active Persona: ${ref.watch(mockRbacProvider).testingUserName ?? ref.watch(mockRbacProvider).activeRole.displayName}',
                style: TextStyle(color: colors.secondaryText, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Consumer(
                builder: (context, ref, child) {
                  final users = ref.watch(mockUserListProvider);
                  final currentUserId = ref.watch(mockRbacProvider).testingUserId ?? 'USR-001';

                  return DropdownButton<String>(
                    isExpanded: true,
                    value: users.any((u) => u.id == currentUserId) ? currentUserId : users.first.id,
                    dropdownColor: colors.card,
                    items: users.map((u) {
                      final label = u.isSuperAdmin
                          ? '${u.name} (Trust President • Super Admin)'
                          : '${u.name} (${u.role.displayName})';
                      return DropdownMenuItem<String>(
                        value: u.id,
                        child: Text(
                          label,
                          style: TextStyle(color: colors.text, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (userId) {
                      if (userId != null) {
                        final selectedUser = users.firstWhere((u) => u.id == userId);
                        ref.read(mockRbacProvider.notifier).simulateUserAccess(selectedUser);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Switched persona to: ${selectedUser.name}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
