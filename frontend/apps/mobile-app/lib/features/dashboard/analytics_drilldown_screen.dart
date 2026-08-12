import 'package:flutter/material.dart';

import '../../shared/ui_kit/cards/allocation_card.dart';
import '../../shared/ui_kit/charts/app_bar_chart.dart';
import '../../shared/ui_kit/chips/status_chip.dart';
import 'models/dashboard_models.dart';

/// Entered by tapping a chart segment (rather than a KPI) -- a donut slice
/// or bar isn't a single number, it's a filter. This screen answers
/// "show me exactly what makes up that share."
class AnalyticsDrilldownScreen extends StatelessWidget {
  final DrilldownData data;

  const AnalyticsDrilldownScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(data.chartTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${data.segmentName.toUpperCase()} · ${data.segmentShareLabel}',
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSecondaryContainer
                              .withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.segmentValueLabel,
                        style: textTheme.headlineMedium
                            ?.copyWith(color: colorScheme.onSecondaryContainer),
                      ),
                    ],
                  ),
                ),
                StatusChip(
                  label: data.budgetStatusLabel,
                  type: data.isOverBudget
                      ? StatusChipType.error
                      : StatusChipType.success,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Sub-items', style: textTheme.titleMedium),
          const SizedBox(height: 12),
          AppBarChart(
            groups: [
              for (final item in data.subItems)
                BarGroup(label: item.label, primaryValue: item.value)
            ],
            primaryColor: colorScheme.secondary,
          ),
          const SizedBox(height: 24),
          Text('Vendor breakdown', style: textTheme.titleMedium),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  for (final vendor in data.vendors)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Text(vendor.vendorName,
                                  style: textTheme.bodyLarge)),
                          const SizedBox(width: 8),
                          Text(vendor.amountLabel, style: textTheme.bodyLarge),
                          const SizedBox(width: 8),
                          StatusChip(
                            label: vendor.statusLabel,
                            type: vendor.isPaid
                                ? StatusChipType.success
                                : StatusChipType.warning,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Linked budget category', style: textTheme.titleMedium),
          const SizedBox(height: 12),
          AllocationCard(
            icon: Icons.account_balance_wallet_outlined,
            name: data.linkedCategoryName,
            progress: data.isOverBudget ? 1.04 : 0.7,
            spentLabel: data.segmentValueLabel,
            allocatedLabel: data.segmentValueLabel,
            trailing: StatusChip(
              label: data.linkedCategoryStatusLabel,
              type: data.isOverBudget
                  ? StatusChipType.error
                  : StatusChipType.success,
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
