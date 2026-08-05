import 'package:flutter/material.dart';

import '../../shared/ui_kit/layout/section_header.dart';
import 'advanced_filters_sheet.dart';
import 'analytics_drilldown_screen.dart';
import 'export_report_sheet.dart';
import 'kpi_detail_screen.dart';
import 'models/dashboard_models.dart';
import 'widgets/analytics_card.dart';
import 'widgets/chart_card.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/financial_summary_card.dart';
import 'widgets/timeline_item.dart';

/// Assembles the dashboard feature widgets into a screen.
///
/// Data below is sample/mock data -- this screen has no backend wiring yet.
/// Replace with real providers once the reports/financial-accounts APIs land.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _headerInfo = DashboardHeaderInfo(
    userName: 'Divya',
    unreadNotificationCount: 3,
    organizationName: 'Ganeshotsav Mandal',
    festivalName: 'Ganesh Chaturthi 2026',
    festivalDay: 4,
    festivalTotalDays: 11,
  );

  static const _summary = FinancialSummaryData(
    availableBalance: '₹4,82,650',
    liveStatusLabel: 'Live',
    progress: 0.68,
    achievedAmount: 682000,
    targetAmount: 1000000,
    todaysCollection: '+₹24,500',
    todaysExpenses: '-₹8,200',
    netBalance: '₹16,300',
  );

  static final _analyticsCards = [
    AnalyticsCardData(
      routeName: 'contributions',
      accentColor: Colors.green.shade700,
      icon: Icons.groups_outlined,
      value: '₹6,82,000',
      label: 'Contributions',
      sparklineData: const [12, 18, 14, 22, 26, 24, 30],
      statusLabel: '128 donors',
    ),

    AnalyticsCardData(
      routeName: 'expenses',
      accentColor: Colors.red.shade700,
      icon: Icons.payments_outlined,
      value: '₹1,99,350',
      label: 'Expenses',
      sparklineData: const [8, 10, 9, 14, 12, 16, 15],
      statusLabel: '42 entries',
    ),

    AnalyticsCardData(
      routeName: 'receipts',
      accentColor: Colors.blue.shade700,
      icon: Icons.receipt_outlined,
      value: '156',
      label: 'Receipts Issued',
      sparklineData: const [4, 6, 5, 9, 8, 11, 13],
      statusLabel: 'All reconciled',
    ),

    AnalyticsCardData(
      routeName: 'reports',
      accentColor: Colors.purple.shade700,
      icon: Icons.bar_chart_outlined,
      value: '3',
      label: 'Reports Due',
      sparklineData: const [1, 2, 1, 3, 2, 3, 3],
      statusLabel: 'Due this week',
    ),

    // NEW: Budget
    AnalyticsCardData(
      routeName: 'budget',
      accentColor: Colors.orange.shade700,
      icon: Icons.account_balance_wallet_outlined,
      value: '₹25.0L',
      label: 'Budget',
      sparklineData: const [20, 24, 22, 28, 30, 27, 35],
      statusLabel: '2 approvals pending',
    ),

    // NEW: Audit Log
    AnalyticsCardData(
      routeName: 'audit',
      accentColor: Colors.indigo.shade700,
      icon: Icons.history_outlined,
      value: '128',
      label: 'Audit Logs',
      sparklineData: const [10, 14, 12, 18, 20, 16, 22],
      statusLabel: '3 critical events',
    ),

    // NEW: Notifications
    AnalyticsCardData(
      routeName: 'dashboard-notifications',
      accentColor: Colors.redAccent.shade700,
      icon: Icons.notifications_outlined,
      value: '9',
      label: 'Notifications',
      sparklineData: const [5, 7, 6, 8, 9, 7, 9],
      statusLabel: '2 critical alerts',
    ),
  ];

  static const _chartTabs = [
    ChartTabData(
      title: 'Collections',
      values: [12, 18, 14, 22, 26, 24, 30],
      labels: ['Mon', '', '', '', '', '', 'Sun'],
    ),
    ChartTabData(
      title: 'Expenses',
      values: [8, 10, 9, 14, 12, 16, 15],
      labels: ['Mon', '', '', '', '', '', 'Sun'],
    ),
  ];

  static final _balanceDetail = KpiDetailData(
    title: 'Available Balance',
    valueLabel: '₹4,82,650',
    deltaLabel: '4.1%',
    comparisonCaption: 'Updated just now · Festival Day 4 of 11',
    trendValues: const [3.6, 3.9, 4.0, 4.3, 4.5, 4.7, 4.83],
    highlightIndex: 6,
    highlightLabel: '₹4.83L · Today',
    thisPeriodLabel: 'This Week',
    thisPeriodValue: '₹4,82,650',
    lastPeriodLabel: 'Last Week',
    lastPeriodValue: '₹4,63,900',
    breakdown: const [
      KpiBreakdownItem(
          label: 'Contributions', valueLabel: '₹6.82L', progress: 0.61),
      KpiBreakdownItem(
          label: 'Sponsorships', valueLabel: '₹5.1L', progress: 0.28),
      KpiBreakdownItem(
          label: 'Advertising', valueLabel: '₹2.1L', progress: 0.11),
    ],
    relatedTransactions: _activity,
  );

  static const _expenseDrilldown = DrilldownData(
    chartTitle: 'Expense Distribution',
    segmentName: 'Decoration',
    segmentShareLabel: '32% of total',
    segmentValueLabel: '₹1,99,350',
    budgetStatusLabel: 'Over Budget',
    isOverBudget: true,
    subItems: [
      BarGroupData(label: 'Mandap', value: 82000),
      BarGroupData(label: 'Flowers', value: 45200),
      BarGroupData(label: 'Stage', value: 51000),
      BarGroupData(label: 'Lighting', value: 21150),
    ],
    vendors: [
      DrilldownVendorRow(
          vendorName: 'Shubh Decorators',
          amountLabel: '₹82,000',
          statusLabel: 'Paid',
          isPaid: true),
      DrilldownVendorRow(
          vendorName: 'Flora Fresh',
          amountLabel: '₹45,200',
          statusLabel: 'Pending',
          isPaid: false),
    ],
    linkedCategoryName: 'Decoration',
    linkedCategoryStatusLabel: 'Over by ₹18,200',
  );

  static final _activity = [
    ActivityItemData(
      type: ActivityType.contribution,
      title: 'Contribution received',
      subtitle: 'Sharma Family',
      amount: '+₹5,000',
      timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
    ActivityItemData(
      type: ActivityType.expense,
      title: 'Decoration vendor paid',
      subtitle: 'Shubh Decorators',
      statusLabel: 'Approved',
      amount: '-₹8,200',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ActivityItemData(
      type: ActivityType.receipt,
      title: 'Receipt #0156 issued',
      subtitle: 'Patil Family',
      amount: '+₹1,100',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    ActivityItemData(
      type: ActivityType.audit,
      title: 'Ledger reconciled',
      subtitle: 'Treasurer review',
      statusLabel: 'Completed',
      timestamp: DateTime.now().subtract(const Duration(hours: 9)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Ganeshotsav 2026'),
        actions: [
          IconButton(
            onPressed: () => DashboardFiltersSheet.show(context),
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: () => ExportReportSheet.show(context),
            icon: const Icon(Icons.ios_share),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const DashboardHeader(info: _headerInfo),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: -32,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) =>
                              KpiDetailScreen(data: _balanceDetail)),
                    ),
                    child: const FinancialSummaryCard(data: _summary),
                  ),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(title: 'Quick Analytics'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 210,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _analyticsCards.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) =>
                          AnalyticsCard(data: _analyticsCards[index]),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SectionHeader(
                    title: 'Trends',
                    trailing: TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const AnalyticsDrilldownScreen(
                                data: _expenseDrilldown)),
                      ),
                      child: const Text('Drill in →'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const ChartCard(tabs: _chartTabs),
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'Recent Activity'),
                  const SizedBox(height: 4),
                  ..._activity.map((item) => TimelineItem(data: item)),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
