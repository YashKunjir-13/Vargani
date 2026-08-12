import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/ui_kit/cards/allocation_card.dart';
import '../../shared/ui_kit/cards/kpi_card.dart';
import '../../shared/ui_kit/chips/status_chip.dart';
import '../../shared/ui_kit/layout/section_header.dart';
import 'presentation/providers/budget_providers.dart';
import 'models/budget_models.dart';

String _formatCurrency(int paise) {
  final rupees = (paise / 100).round();
  // Simple formatting for mock
  return '₹$rupees';
}

class BudgetOverviewScreen extends ConsumerWidget {
  final VoidCallback? onOpenFilters;
  final VoidCallback? onOpenExport;
  final VoidCallback? onOpenTable;
  final VoidCallback? onCreateRevision;
  final ValueChanged<MockBudgetCategory>? onOpenCategory;
  final ValueChanged<MockBudgetRevision>? onOpenRevision;

  const BudgetOverviewScreen({
    super.key,
    this.onOpenFilters,
    this.onOpenExport,
    this.onOpenTable,
    this.onCreateRevision,
    this.onOpenCategory,
    this.onOpenRevision,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final budget = ref.watch(budgetProvider);
    if (budget == null) {
      return const Scaffold(
        body: Center(child: Text('Unauthorized or budget not found.')),
      );
    }

    final revisions = ref.watch(budgetRevisionsProvider(budget.id));

    final totalAllocated = budget.totalAllocatedPaise;
    final totalUtilized = budget.totalUtilizedPaise;
    final remaining = budget.remainingPaise;

    final isHealthWarning = remaining < 0;
    final healthLabel = isHealthWarning ? 'Over Budget' : 'On Track';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(budget.title),
            Text(
              '${budget.eventId} · ${budget.version}',
              style: textTheme.labelMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: onOpenFilters, icon: const Icon(Icons.filter_list)),
          IconButton(
              onPressed: onOpenExport, icon: const Icon(Icons.ios_share)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusChip(
                label: healthLabel,
                type: isHealthWarning
                    ? StatusChipType.warning
                    : StatusChipType.success,
                icon: isHealthWarning
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline,
              ),
              Text(
                'Owner: ${budget.ownerUserName}',
                style: textTheme.labelMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: [
              KpiCard(
                  label: 'TOTAL BUDGET',
                  value: _formatCurrency(budget.totalBudgetPaise),
                  caption: 'FY 2025-26'),
              KpiCard(
                  label: 'ALLOCATED', value: _formatCurrency(totalAllocated)),
              KpiCard(
                label: 'UTILIZED',
                value: _formatCurrency(totalUtilized),
                statusBadge: StatusChip(
                  label: isHealthWarning ? 'Warn' : 'OK',
                  type: isHealthWarning
                      ? StatusChipType.warning
                      : StatusChipType.success,
                ),
              ),
              KpiCard(
                  label: 'REMAINING',
                  value: _formatCurrency(remaining),
                  caption: 'Until Event'),
            ],
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Category Allocation',
            trailing: TextButton(
                onPressed: onOpenTable, child: const Text('Full table')),
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  for (final category in budget.categories) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: AllocationCard(
                        icon: _getIconData(category.iconName),
                        name: category.name,
                        progress: category.allocatedPaise > 0
                            ? (category.utilizedPaise / category.allocatedPaise)
                            : 0,
                        spentLabel: _formatCurrency(category.utilizedPaise),
                        allocatedLabel:
                            _formatCurrency(category.allocatedPaise),
                        footnote: category.footnote,
                        trailing: StatusChip(
                          label:
                              '${category.allocatedPaise > 0 ? ((category.utilizedPaise / category.allocatedPaise) * 100).toStringAsFixed(0) : 0}%',
                          type: AllocationCard.statusForProgress(
                              category.allocatedPaise > 0
                                  ? (category.utilizedPaise /
                                      category.allocatedPaise)
                                  : 0),
                        ),
                        onTap: onOpenCategory == null
                            ? null
                            : () => onOpenCategory!(category),
                      ),
                    ),
                    if (category != budget.categories.last)
                      const Divider(height: 1),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Revision Timeline',
            trailing: TextButton(
                onPressed: onCreateRevision, child: const Text('New revision')),
          ),
          const SizedBox(height: 8),
          for (final revision in revisions)
            ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: onOpenRevision == null
                  ? null
                  : () => onOpenRevision!(revision),
              title: Text(revision.title,
                  style: textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              subtitle: Text(
                [
                  '${revision.version} · ${_formatDate(revision.requestedAt)}',
                  if (revision.reason != null) revision.reason!,
                ].join('\n'),
              ),
              trailing: StatusChip(
                label: revision.status,
                type: revision.status == 'Pending'
                    ? StatusChipType.warning
                    : (revision.status == 'Approved'
                        ? StatusChipType.success
                        : StatusChipType.neutral),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'home_repair_service':
        return Icons.home_repair_service;
      case 'restaurant':
        return Icons.restaurant;
      case 'speaker':
        return Icons.speaker;
      default:
        return Icons.category;
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
