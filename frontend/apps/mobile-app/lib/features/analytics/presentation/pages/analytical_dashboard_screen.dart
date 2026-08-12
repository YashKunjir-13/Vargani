import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/ui_kit/charts/app_donut_chart.dart';
import '../../../../shared/widgets/pauti_app_bar.dart';
import '../../../authentication/presentation/widgets/auth_design_tokens.dart';
import '../../../dashboard/presentation/widgets/analytics_charts.dart';
import '../../../dashboard/presentation/widgets/summary_card.dart';
import '../../models/analytics_models.dart';
import '../providers/analytics_provider.dart';

class AnalyticalDashboardScreen extends ConsumerWidget {
  const AnalyticalDashboardScreen({super.key});

  String _formatIndianCurrency(int paise) {
    final rupees = (paise / 100).floor();
    final isNegative = rupees < 0;
    final str = rupees.abs().toString();
    if (str.length <= 3) {
      return '${isNegative ? "-₹" : "₹"}$str';
    }
    final last3 = str.substring(str.length - 3);
    final remaining = str.substring(0, str.length - 3);
    final formattedRemaining = remaining.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{2})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '${isNegative ? "-₹" : "₹"}$formattedRemaining,$last3';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.authColors;
    final state = ref.watch(analyticsProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const PautiAppBar(
        title: 'Analytical Dashboard',
        subtitle: 'Financial & Operational Intelligence',
        showBackButton: true,
      ),
      body: SafeArea(
        child: _buildBody(context, ref, state, colors),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, AnalyticsState state,
      AuthColors colors) {
    if (state.isUnauthorized) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lock_outline,
                    size: 48, color: colors.secondaryText),
              ),
              const SizedBox(height: 20),
              Text(
                'Access Restricted',
                style: TextStyle(
                    color: colors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                'You do not have permission to view the Analytical Dashboard (analytics.view required).',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.secondaryText, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: colors.brandOrange),
            const SizedBox(height: 16),
            Text(
              'Loading Analytics...',
              style: TextStyle(
                  color: colors.secondaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                'Failed to load analytics',
                style: TextStyle(
                    color: colors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(state.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.secondaryText, fontSize: 13)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => ref.read(analyticsProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.brandOrange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final data = state.data;
    if (data == null) {
      return Center(
        child: Text(
          'No analytical data recorded.',
          style: TextStyle(color: colors.secondaryText, fontSize: 14),
        ),
      );
    }

    return RefreshIndicator(
      color: colors.brandOrange,
      onRefresh: () async {
        ref.read(analyticsProvider.notifier).refresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. DATE RANGE FILTER (Responsive Horizontal Scrollable Chips)
            _buildSectionHeader(colors, 'DATE RANGE FILTER'),
            const SizedBox(height: 10),
            _buildDateFilterChips(context, ref, state, colors),

            const SizedBox(height: 24),

            // 2. FINANCIAL HERO SUMMARY
            _buildSectionHeader(colors, 'FINANCIAL OVERVIEW'),
            const SizedBox(height: 10),
            HeroOverviewCard(
              tagline: 'FESTIVAL NET BALANCE',
              mainAmount:
                  _formatIndianCurrency(data.financialMetrics.netBalancePaise),
              subtitle: 'Total Receipts + Sponsorships + Ads vs Total Bills',
              stat1Label: 'Inflow',
              stat1Value:
                  _formatIndianCurrency(data.financialMetrics.totalInflowPaise),
              stat2Label: 'Outflow',
              stat2Value: _formatIndianCurrency(
                  data.financialMetrics.totalOutflowPaise),
              stat3Label: 'Surplus',
              stat3Value:
                  _formatIndianCurrency(data.financialMetrics.netBalancePaise),
            ),

            const SizedBox(height: 24),

            // 3. INFLOW VS OUTFLOW VISUALIZATION
            _buildSectionHeader(colors, 'INFLOW VS OUTFLOW VISUALIZATION'),
            const SizedBox(height: 10),
            IncomeVsExpenseCard(
              incomePaise: data.financialMetrics.totalInflowPaise,
              expensePaise: data.financialMetrics.totalOutflowPaise,
            ),

            const SizedBox(height: 24),

            // 4. OPERATIONAL VISUAL CHARTS (Milestones Progress & Audit Severity)
            _buildSectionHeader(colors, 'OPERATIONAL VISUAL ANALYTICS'),
            const SizedBox(height: 10),
            _buildVisualAnalyticsRow(context, data, colors),

            const SizedBox(height: 24),

            // 5. ALL 8 MODULE RECORDS SUMMARY CARDS
            _buildSectionHeader(colors, 'MODULE RECORDS SUMMARY'),
            const SizedBox(height: 12),
            _buildModuleCardsGrid(context, data, colors),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(AuthColors colors, String title) {
    return Text(
      title,
      style: TextStyle(
        color: colors.secondaryText,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildDateFilterChips(BuildContext context, WidgetRef ref,
      AnalyticsState state, AuthColors colors) {
    final filters = [
      {'filter': DateRangeFilter.entireFestival, 'label': 'All Time'},
      {'filter': DateRangeFilter.today, 'label': 'Today'},
      {'filter': DateRangeFilter.thisWeek, 'label': 'This Week'},
      {'filter': DateRangeFilter.thisMonth, 'label': 'This Month'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((item) {
          final filter = item['filter'] as DateRangeFilter;
          final label = item['label'] as String;
          final isSelected = state.filter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : colors.text,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              selected: isSelected,
              selectedColor: colors.brandOrange,
              backgroundColor: colors.card,
              side: BorderSide(
                  color: isSelected ? colors.brandOrange : colors.border),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              onSelected: (selected) {
                if (selected) {
                  ref.read(analyticsProvider.notifier).setFilter(filter);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVisualAnalyticsRow(
      BuildContext context, AnalyticalDashboardData data, AuthColors colors) {
    final isCompact = MediaQuery.of(context).size.width < 600;

    final milestoneChart = _buildChartCard(
      context,
      colors,
      title: 'Milestone Progress',
      slices: [
        DonutSlice(
            label: 'Completed',
            value: data.milestoneSummary.completed.toDouble(),
            color: Colors.green),
        DonutSlice(
            label: 'In Progress',
            value: data.milestoneSummary.inProgress.toDouble(),
            color: colors.brandOrange),
        DonutSlice(
            label: 'Pending',
            value: data.milestoneSummary.pending.toDouble(),
            color: Colors.amber),
      ],
      centerText: '${data.milestoneSummary.totalMilestones}',
      centerLabel: 'Milestones',
      legendItems: [
        _LegendItem(
            label: 'Completed',
            value: '${data.milestoneSummary.completed}',
            color: Colors.green),
        _LegendItem(
            label: 'In Progress',
            value: '${data.milestoneSummary.inProgress}',
            color: colors.brandOrange),
        _LegendItem(
            label: 'Pending',
            value: '${data.milestoneSummary.pending}',
            color: Colors.amber),
      ],
    );

    final auditChart = _buildChartCard(
      context,
      colors,
      title: 'Audit Record Severity',
      slices: [
        DonutSlice(
            label: 'Passed',
            value: data.auditSummary.passedRecords.toDouble(),
            color: Colors.green),
        DonutSlice(
            label: 'Warnings',
            value: data.auditSummary.warnings.toDouble(),
            color: Colors.amber),
        DonutSlice(
            label: 'Critical',
            value: data.auditSummary.criticalFindings.toDouble(),
            color: Colors.redAccent),
      ],
      centerText: '${data.auditSummary.totalEvents}',
      centerLabel: 'Events',
      legendItems: [
        _LegendItem(
            label: 'Passed',
            value: '${data.auditSummary.passedRecords}',
            color: Colors.green),
        _LegendItem(
            label: 'Warnings',
            value: '${data.auditSummary.warnings}',
            color: Colors.amber),
        _LegendItem(
            label: 'Critical',
            value: '${data.auditSummary.criticalFindings}',
            color: Colors.redAccent),
      ],
    );

    if (isCompact) {
      return Column(
        children: [
          milestoneChart,
          const SizedBox(height: 12),
          auditChart,
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: milestoneChart),
          const SizedBox(width: 12),
          Expanded(child: auditChart),
        ],
      );
    }
  }

  Widget _buildChartCard(
    BuildContext context,
    AuthColors colors, {
    required String title,
    required List<DonutSlice> slices,
    required String centerText,
    required String centerLabel,
    required List<_LegendItem> legendItems,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
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
            title,
            style: TextStyle(
                color: colors.text, fontSize: 15, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  AppDonutChart(slices: slices, size: 84, strokeWidth: 12),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        centerText,
                        style: TextStyle(
                            color: colors.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w900),
                      ),
                      Text(
                        centerLabel,
                        style: TextStyle(
                            color: colors.secondaryText,
                            fontSize: 9,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: legendItems.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                    color: item.color, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item.label,
                                style: TextStyle(
                                    color: colors.secondaryText,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          Text(
                            item.value,
                            style: TextStyle(
                                color: colors.text,
                                fontSize: 12,
                                fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCardsGrid(
      BuildContext context, AnalyticalDashboardData data, AuthColors colors) {
    final cards = [
      GlassStatCard(
        title: 'Audit Records',
        value: '${data.auditSummary.totalEvents} Events',
        subtitle:
            'Warnings: ${data.auditSummary.warnings} • Critical: ${data.auditSummary.criticalFindings}',
        icon: Icons.security_outlined,
      ),
      GlassStatCard(
        title: 'Bills Records',
        value: _formatIndianCurrency(data.billSummary.totalBilledPaise),
        subtitle:
            '${data.billSummary.totalBills} Bills • ${data.billSummary.pendingBills} Pending',
        icon: Icons.description_outlined,
      ),
      GlassStatCard(
        title: 'Receipt Records',
        value:
            _formatIndianCurrency(data.receiptSummary.totalReceiptAmountPaise),
        subtitle:
            '${data.receiptSummary.totalReceipts} Total • ${data.receiptSummary.todaysReceipts} Today',
        icon: Icons.receipt_outlined,
      ),
      GlassStatCard(
        title: 'Sponsorship Records',
        value: _formatIndianCurrency(
            data.sponsorshipSummary.totalSponsorshipAmountPaise),
        subtitle:
            '${data.sponsorshipSummary.activeSponsors} Active • ${data.sponsorshipSummary.totalSponsorships} Total',
        icon: Icons.handshake_outlined,
      ),
      GlassStatCard(
        title: 'Vendor Records',
        value: '${data.vendorSummary.totalVendors} Vendors',
        subtitle: '${data.vendorSummary.activeVendors} Active Contracts',
        icon: Icons.storefront_outlined,
      ),
      GlassStatCard(
        title: 'Advertiser Records',
        value: _formatIndianCurrency(
            data.advertiserSummary.associatedRevenuePaise),
        subtitle:
            '${data.advertiserSummary.totalAdvertisers} Advertisers Active',
        icon: Icons.campaign_outlined,
      ),
      GlassStatCard(
        title: 'Milestone Records',
        value: '${data.milestoneSummary.totalMilestones} Milestones',
        subtitle:
            '${data.milestoneSummary.completed} Complete • ${data.milestoneSummary.inProgress} In Progress',
        icon: Icons.flag_outlined,
      ),
      GlassStatCard(
        title: 'Contribution Records',
        value: '${data.contributionSummary.totalContributions} Total',
        subtitle:
            'Types: ${data.contributionSummary.breakdownByType.keys.take(3).join(', ')}',
        icon: Icons.monetization_on_outlined,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.15,
          ),
          itemBuilder: (context, index) => cards[index],
        );
      },
    );
  }
}

class _LegendItem {
  final String label;
  final String value;
  final Color color;

  const _LegendItem(
      {required this.label, required this.value, required this.color});
}
