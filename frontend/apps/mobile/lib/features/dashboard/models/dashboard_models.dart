import 'package:flutter/material.dart';

class DashboardHeaderInfo {
  final String userName;
  final int unreadNotificationCount;
  final String organizationName;
  final String festivalName;
  final int festivalDay;
  final int festivalTotalDays;

  const DashboardHeaderInfo({
    required this.userName,
    required this.unreadNotificationCount,
    required this.organizationName,
    required this.festivalName,
    required this.festivalDay,
    required this.festivalTotalDays,
  });
}

class FinancialSummaryData {
  final String availableBalance;
  final String liveStatusLabel;
  final double progress;
  final num achievedAmount;
  final num targetAmount;
  final String todaysCollection;
  final String todaysExpenses;
  final String netBalance;

  const FinancialSummaryData({
    required this.availableBalance,
    required this.liveStatusLabel,
    required this.progress,
    required this.achievedAmount,
    required this.targetAmount,
    required this.todaysCollection,
    required this.todaysExpenses,
    required this.netBalance,
  });
}

class AnalyticsCardData {
  final String routeName;
  final Color accentColor;
  final IconData icon;
  final String value;
  final String label;
  final List<double> sparklineData;
  final String statusLabel;

  const AnalyticsCardData({
    required this.routeName,
    required this.accentColor,
    required this.icon,
    required this.value,
    required this.label,
    required this.sparklineData,
    required this.statusLabel,
  });
}

class ChartTabData {
  final String title;
  final List<double> values;
  final List<String>? labels;

  const ChartTabData({
    required this.title,
    required this.values,
    this.labels,
  });
}

enum ActivityType { receipt, expense, contribution, audit, notification, vendor, sponsor }

class ActivityItemData {
  final ActivityType type;
  final String title;
  final String subtitle;
  final String? statusLabel;
  final String? amount;
  final DateTime timestamp;

  const ActivityItemData({
    required this.type,
    required this.title,
    required this.subtitle,
    this.statusLabel,
    this.amount,
    required this.timestamp,
  });
}

/// One "breakdown by type" row on the KPI Detail screen, e.g.
/// "Individual Donations -- 61% -- ₹11.2L".
class KpiBreakdownItem {
  final String label;
  final String valueLabel;
  final double progress;

  const KpiBreakdownItem({
    required this.label,
    required this.valueLabel,
    required this.progress,
  });
}

/// Full detail payload for the KPI Detail screen.
class KpiDetailData {
  final String title;
  final String valueLabel;
  final String deltaLabel;
  final String comparisonCaption;
  final List<double> trendValues;
  final int highlightIndex;
  final String highlightLabel;
  final String thisPeriodLabel;
  final String thisPeriodValue;
  final String lastPeriodLabel;
  final String lastPeriodValue;
  final List<KpiBreakdownItem> breakdown;
  final List<ActivityItemData> relatedTransactions;

  const KpiDetailData({
    required this.title,
    required this.valueLabel,
    required this.deltaLabel,
    required this.comparisonCaption,
    required this.trendValues,
    required this.highlightIndex,
    required this.highlightLabel,
    required this.thisPeriodLabel,
    required this.thisPeriodValue,
    required this.lastPeriodLabel,
    required this.lastPeriodValue,
    required this.breakdown,
    required this.relatedTransactions,
  });
}

/// One vendor row in the Analytics Drill-down's vendor breakdown table.
class DrilldownVendorRow {
  final String vendorName;
  final String amountLabel;
  final String statusLabel;
  final bool isPaid;

  const DrilldownVendorRow({
    required this.vendorName,
    required this.amountLabel,
    required this.statusLabel,
    required this.isPaid,
  });
}

/// Full payload for the Analytics Drill-down screen (entered from a chart
/// segment, e.g. the Decoration slice of the expense distribution donut).
class DrilldownData {
  final String chartTitle;
  final String segmentName;
  final String segmentShareLabel;
  final String segmentValueLabel;
  final String budgetStatusLabel;
  final bool isOverBudget;
  final List<BarGroupData> subItems;
  final List<DrilldownVendorRow> vendors;
  final String linkedCategoryName;
  final String linkedCategoryStatusLabel;

  const DrilldownData({
    required this.chartTitle,
    required this.segmentName,
    required this.segmentShareLabel,
    required this.segmentValueLabel,
    required this.budgetStatusLabel,
    required this.isOverBudget,
    required this.subItems,
    required this.vendors,
    required this.linkedCategoryName,
    required this.linkedCategoryStatusLabel,
  });
}

/// A single sub-item bar in the drill-down's bar chart -- kept as plain
/// data here (rather than importing the ui_kit chart's own type) so this
/// model file has no dependency on chart rendering.
class BarGroupData {
  final String label;
  final double value;

  const BarGroupData({required this.label, required this.value});
}
