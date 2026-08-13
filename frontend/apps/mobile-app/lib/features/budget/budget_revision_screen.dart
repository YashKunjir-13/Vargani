import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/ui_kit/buttons/primary_button.dart';
import '../../shared/ui_kit/buttons/secondary_button.dart';
import '../../shared/ui_kit/chips/status_chip.dart';
import '../rbac/presentation/providers/mock_rbac_provider.dart';
import 'presentation/providers/budget_providers.dart';
import 'models/budget_models.dart';

String _formatCurrency(int paise) {
  return '₹${(paise / 100).round()}';
}

/// Creating a revision never edits the active budget in place -- it drafts
/// a new version that only takes effect after approval, so the Active
/// budget stays trustworthy for anyone viewing it mid-review.
class BudgetRevisionScreen extends ConsumerStatefulWidget {
  const BudgetRevisionScreen({super.key});

  @override
  ConsumerState<BudgetRevisionScreen> createState() =>
      _BudgetRevisionScreenState();
}

class _BudgetRevisionScreenState extends ConsumerState<BudgetRevisionScreen> {
  final _reasonController = TextEditingController();
  final _titleController =
      TextEditingController(text: 'Budget Revision Request');
  List<MockRevisionAdjustment>? _adjustments;

  @override
  void dispose() {
    _reasonController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _submitForApproval() {
    final budget = ref.read(budgetProvider);
    if (budget == null) return;
    final rbacState = ref.read(mockRbacProvider);

    final revision = MockBudgetRevision(
      id: 'REV-${DateTime.now().millisecondsSinceEpoch}',
      budgetId: budget.id,
      version: '${budget.version} -> next',
      title: _titleController.text,
      reason: _reasonController.text,
      status: 'Pending',
      requestedByUserId: rbacState.testingUserId ?? 'USR-000',
      requestedByUserName: rbacState.testingUserName ?? 'Unknown',
      requestedAt: DateTime.now(),
      adjustments: _adjustments ?? [],
      comments: [],
    );

    ref.read(budgetActionsProvider).requestRevision(revision);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Revision submitted')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final budget = ref.watch(budgetProvider);
    if (budget == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('New Revision')),
        body: const Center(child: Text('Budget unavailable')),
      );
    }

    if (_adjustments == null && budget.categories.isNotEmpty) {
      final cat = budget.categories.first;
      _adjustments = [
        MockRevisionAdjustment(
          categoryId: cat.id,
          categoryName: cat.name,
          currentAllocationPaise: cat.allocatedPaise,
          proposedAllocationPaise:
              cat.allocatedPaise + 5000000, // add ₹50,000 for mock
        )
      ];
    }

    final adjustments = _adjustments ?? [];

    // In a real app we'd calculate net change across all categories
    final int netChange = adjustments.fold(
        0,
        (sum, a) =>
            sum + (a.proposedAllocationPaise - a.currentAllocationPaise));
    final netChangeBalances = netChange == 0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('New Revision'),
            Text('Draft',
                style: textTheme.labelMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Title',
              style: textTheme.labelMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'Short title for revision',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text('Reason for revision',
              style: textTheme.labelMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          TextField(
            controller: _reasonController,
            decoration: const InputDecoration(
              hintText: 'Why is this revision needed?',
              border: OutlineInputBorder(),
            ),
            minLines: 2,
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          Text('Adjust allocations', style: textTheme.titleMedium),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                if (adjustments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No adjustments'),
                  )
                else
                  for (final adjustment in adjustments)
                    ListTile(
                      title: Text(adjustment.categoryName,
                          style: textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      subtitle: Text(
                          'Current ${_formatCurrency(adjustment.currentAllocationPaise)}'),
                      trailing: Text(
                        _formatCurrency(adjustment.proposedAllocationPaise),
                        style: textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: netChangeBalances
                  ? colorScheme.tertiaryContainer
                  : colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  netChangeBalances
                      ? 'Net change balances to zero'
                      : 'Net change does not balance',
                  style: textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                StatusChip(
                  label: netChangeBalances
                      ? '₹0'
                      : (netChange > 0
                          ? '+${_formatCurrency(netChange)}'
                          : _formatCurrency(netChange)),
                  type: netChangeBalances
                      ? StatusChipType.success
                      : StatusChipType.error,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                  child: SecondaryButton(
                      label: 'Cancel', onPressed: () => context.pop())),
              const SizedBox(width: 8),
              Expanded(
                  child: PrimaryButton(
                      label: 'Submit for Approval',
                      onPressed: _submitForApproval)),
            ],
          ),
        ),
      ),
    );
  }
}
