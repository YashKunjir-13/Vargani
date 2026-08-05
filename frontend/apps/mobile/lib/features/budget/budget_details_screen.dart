import 'package:flutter/material.dart';

import '../../shared/ui_kit/buttons/secondary_button.dart';
import '../../shared/ui_kit/cards/kpi_card.dart';
import '../../shared/ui_kit/chips/status_chip.dart';
import 'models/budget_models.dart';

/// Full-screen category detail, entered by tapping a category on the
/// Budget Overview -- an over-budget category needs its linked expenses,
/// vendors, and approval history in one place, not scattered across screens.
class BudgetDetailsScreen extends StatelessWidget {
  final BudgetCategoryData category;
  final List<LinkedExpense> linkedExpenses;
  final String approvalHistoryNote;
  final VoidCallback? onRequestAdditionalAllocation;

  const BudgetDetailsScreen({
    super.key,
    required this.category,
    required this.linkedExpenses,
    required this.approvalHistoryNote,
    this.onRequestAdditionalAllocation,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final overBudget = category.progress >= 1.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: StatusChip(
                label: category.percentLabel,
                type: overBudget ? StatusChipType.error : StatusChipType.success,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: KpiCard(label: 'ALLOCATED', value: category.allocatedLabel)),
              const SizedBox(width: 10),
              Expanded(
                child: KpiCard(
                  label: 'SPENT',
                  value: category.spentLabel,
                  trend: overBudget ? const KpiTrend(direction: TrendDirection.up, label: 'Over', sentiment: TrendSentiment.negative) : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: category.progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(overBudget ? colorScheme.error : colorScheme.primary),
            ),
          ),
          if (overBudget) ...[
            const SizedBox(height: 6),
            Text(
              'Over allocation',
              style: textTheme.labelMedium?.copyWith(color: colorScheme.error, fontWeight: FontWeight.w700),
            ),
          ],
          const SizedBox(height: 24),
          Text('Linked expenses', style: textTheme.titleMedium),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                for (final expense in linkedExpenses)
                  ListTile(
                    title: Text(expense.vendorName),
                    subtitle: Text(expense.dateLabel),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(expense.amountLabel, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                        StatusChip(
                          label: expense.statusLabel,
                          type: expense.isPaid ? StatusChipType.success : StatusChipType.warning,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Approval history', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(approvalHistoryNote, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          Text('Owner', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(category.ownerName, style: textTheme.bodyLarge),
          const SizedBox(height: 24),
          SecondaryButton(
            label: 'Request additional allocation',
            onPressed: onRequestAdditionalAllocation,
            expand: true,
          ),
        ],
      ),
    );
  }
}
