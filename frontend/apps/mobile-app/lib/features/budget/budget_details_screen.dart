import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/ui_kit/buttons/secondary_button.dart';
import '../../shared/ui_kit/cards/kpi_card.dart';
import '../../shared/ui_kit/chips/status_chip.dart';
import 'presentation/providers/budget_providers.dart';

String _formatCurrency(int paise) {
  return '₹${(paise / 100).round()}';
}

String _formatDate(DateTime dt) {
  return '${dt.day}/${dt.month}/${dt.year}';
}

/// Full-screen category detail, entered by tapping a category on the
/// Budget Overview. Watches providers to stay updated.
class BudgetDetailsScreen extends ConsumerWidget {
  final String categoryId;
  final VoidCallback? onRequestAdditionalAllocation;

  const BudgetDetailsScreen({
    super.key,
    required this.categoryId,
    this.onRequestAdditionalAllocation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final budget = ref.watch(budgetProvider);
    if (budget == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Budget Details')),
        body: const Center(child: Text('Budget data unavailable')),
      );
    }

    final category = budget.categories.firstWhere((c) => c.id == categoryId,
        orElse: () => budget.categories.first);
    final linkedExpenses = ref.watch(linkedExpensesProvider(category.id));

    final progress = category.allocatedPaise > 0
        ? (category.utilizedPaise / category.allocatedPaise)
        : 0.0;
    final overBudget = progress >= 1.0;
    final percentLabel = '${(progress * 100).toStringAsFixed(0)}%';

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: StatusChip(
                label: percentLabel,
                type:
                    overBudget ? StatusChipType.error : StatusChipType.success,
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
              Expanded(
                  child: KpiCard(
                      label: 'ALLOCATED',
                      value: _formatCurrency(category.allocatedPaise))),
              const SizedBox(width: 10),
              Expanded(
                child: KpiCard(
                  label: 'SPENT',
                  value: _formatCurrency(category.utilizedPaise),
                  trend: overBudget
                      ? const KpiTrend(
                          direction: TrendDirection.up,
                          label: 'Over',
                          sentiment: TrendSentiment.negative)
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(
                  overBudget ? colorScheme.error : colorScheme.primary),
            ),
          ),
          if (overBudget) ...[
            const SizedBox(height: 6),
            Text(
              'Over allocation',
              style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.error, fontWeight: FontWeight.w700),
            ),
          ],
          const SizedBox(height: 24),
          Text('Linked expenses', style: textTheme.titleMedium),
          const SizedBox(height: 12),
          if (linkedExpenses.isEmpty)
            Text('No expenses linked yet.',
                style: textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant))
          else
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final expense in linkedExpenses)
                    ListTile(
                      title: Text(expense.vendorName),
                      subtitle: Text(_formatDate(expense.date)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(_formatCurrency(expense.amountPaise),
                              style: textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          StatusChip(
                            label: expense.status,
                            type: expense.isPaid
                                ? StatusChipType.success
                                : StatusChipType.warning,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          Text('Owner', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(category.ownerUserName, style: textTheme.bodyLarge),
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
