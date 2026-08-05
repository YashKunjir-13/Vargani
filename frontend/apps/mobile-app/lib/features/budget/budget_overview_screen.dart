import 'package:flutter/material.dart';

import '../../shared/ui_kit/cards/allocation_card.dart';
import '../../shared/ui_kit/cards/kpi_card.dart';
import '../../shared/ui_kit/chips/status_chip.dart';
import '../../shared/ui_kit/layout/section_header.dart';
import 'models/budget_models.dart';

/// The Budget module's hub screen: health status leads, KPIs next, category
/// allocation and revision timeline last -- the enterprise table lives on
/// its own dedicated [BudgetTableScreen], not crammed into this scroll.
class BudgetOverviewScreen extends StatelessWidget {
  final BudgetOverviewData overview;
  final List<BudgetCategoryData> categories;
  final List<RevisionEntry> revisions;
  final VoidCallback? onOpenFilters;
  final VoidCallback? onOpenExport;
  final VoidCallback? onOpenTable;
  final VoidCallback? onCreateRevision;
  final ValueChanged<BudgetCategoryData>? onOpenCategory;
  final ValueChanged<RevisionEntry>? onOpenRevision;

  const BudgetOverviewScreen({
    super.key,
    required this.overview,
    required this.categories,
    required this.revisions,
    this.onOpenFilters,
    this.onOpenExport,
    this.onOpenTable,
    this.onCreateRevision,
    this.onOpenCategory,
    this.onOpenRevision,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Budget'),
            Text(
              'Ganeshotsav 2026 · ${overview.version}',
              style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: onOpenFilters, icon: const Icon(Icons.filter_list)),
          IconButton(onPressed: onOpenExport, icon: const Icon(Icons.ios_share)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusChip(
                label: overview.healthLabel,
                type: overview.isHealthWarning ? StatusChipType.warning : StatusChipType.success,
                icon: overview.isHealthWarning ? Icons.warning_amber_rounded : Icons.check_circle_outline,
              ),
              Text(
                'Owner: ${overview.ownerName}',
                style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
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
              KpiCard(label: 'TOTAL BUDGET', value: overview.totalBudgetLabel, caption: 'FY 2025-26'),
              KpiCard(label: 'ALLOCATED', value: overview.allocatedLabel),
              KpiCard(
                label: 'UTILIZED',
                value: overview.utilizedLabel,
                statusBadge: StatusChip(
                  label: overview.isHealthWarning ? 'Warn' : 'OK',
                  type: overview.isHealthWarning ? StatusChipType.warning : StatusChipType.success,
                ),
              ),
              KpiCard(label: 'REMAINING', value: overview.remainingLabel, caption: overview.daysRemainingCaption),
            ],
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Category Allocation',
            trailing: TextButton(onPressed: onOpenTable, child: const Text('Full table')),
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  for (final category in categories) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: AllocationCard(
                        icon: category.icon,
                        name: category.name,
                        progress: category.progress,
                        spentLabel: category.spentLabel,
                        allocatedLabel: category.allocatedLabel,
                        footnote: category.footnote,
                        trailing: StatusChip(
                          label: category.percentLabel,
                          type: AllocationCard.statusForProgress(category.progress),
                        ),
                        onTap: onOpenCategory == null ? null : () => onOpenCategory!(category),
                      ),
                    ),
                    if (category != categories.last) const Divider(height: 1),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Revision Timeline',
            trailing: TextButton(onPressed: onCreateRevision, child: const Text('New revision')),
          ),
          const SizedBox(height: 8),
          for (final revision in revisions)
            ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: onOpenRevision == null ? null : () => onOpenRevision!(revision),
              title: Text(revision.title, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
              subtitle: Text(
                [
                  '${revision.version} · ${revision.dateLabel}',
                  if (revision.subtitle != null) revision.subtitle!,
                ].join('\n'),
              ),
              trailing: StatusChip(
                label: revision.isPending ? 'Pending' : (revision.isApproved ? 'Approved' : 'Draft'),
                type: revision.isPending
                    ? StatusChipType.warning
                    : (revision.isApproved ? StatusChipType.success : StatusChipType.neutral),
              ),
            ),
        ],
      ),
    );
  }
}
