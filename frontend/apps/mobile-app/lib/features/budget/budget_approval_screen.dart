import 'package:flutter/material.dart' hide StepState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/ui_kit/buttons/primary_button.dart';
import '../../shared/ui_kit/buttons/secondary_button.dart';
import '../../shared/ui_kit/navigation/approval_stepper.dart';
import '../../shared/ui_kit/rows/diff_row.dart';
import 'presentation/providers/budget_providers.dart';
import 'models/budget_models.dart';

String _formatCurrency(int paise) {
  return '₹${(paise / 100).round()}';
}

class BudgetApprovalScreen extends ConsumerStatefulWidget {
  final String revisionId;

  const BudgetApprovalScreen({super.key, required this.revisionId});

  @override
  ConsumerState<BudgetApprovalScreen> createState() =>
      _BudgetApprovalScreenState();
}

class _BudgetApprovalScreenState extends ConsumerState<BudgetApprovalScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _onApprove(MockBudgetRevision revision) {
    try {
      ref.read(budgetActionsProvider).approveRevision(
            revision.id,
            _commentController.text.isNotEmpty
                ? _commentController.text
                : 'Approved',
          );
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Revision approved')));
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _onAddComment(MockBudgetRevision revision) {
    if (_commentController.text.isEmpty) return;
    ref
        .read(budgetActionsProvider)
        .addComment(revision.id, _commentController.text);
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final budget = ref.watch(budgetProvider);
    if (budget == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Budget Approval')),
        body: const Center(child: Text('Unauthorized')),
      );
    }

    final revisions = ref.watch(budgetRevisionsProvider(budget.id));
    final revision = revisions.firstWhere((r) => r.id == widget.revisionId,
        orElse: () => revisions.first);

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Approve Revision ${revision.version}'),
            Text(
              'Submitted by ${revision.requestedByUserName}',
              style: textTheme.labelMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Simplified steps for mock
          ApprovalStepper(steps: [
            ApprovalStep(
              label: 'Submitted by ${revision.requestedByUserName}',
              state: StepState.done,
            ),
            ApprovalStep(
              label: revision.status == 'Approved'
                  ? 'Approved by ${revision.approvedByUserName}'
                  : 'Pending Approval',
              state: revision.status == 'Approved'
                  ? StepState.done
                  : StepState.current,
            ),
          ]),
          const SizedBox(height: 24),
          Text('What changed', style: textTheme.titleMedium),
          const SizedBox(height: 12),
          for (final change in revision.adjustments) ...[
            Text(
              '${change.categoryName} — allocated amount',
              style: textTheme.labelMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            DiffRow(
              oldValue: _formatCurrency(change.currentAllocationPaise),
              newValue: _formatCurrency(change.proposedAllocationPaise),
            ),
            const SizedBox(height: 12),
          ],
          if (revision.reason != null && revision.reason!.isNotEmpty)
            Text(
              'Reason: "${revision.reason}"',
              style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic),
            ),
          const SizedBox(height: 24),
          Text('Comments', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final comment in revision.comments)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      comment.authorUserName.isNotEmpty
                          ? comment.authorUserName.substring(0, 1).toUpperCase()
                          : 'U',
                      style: textTheme.labelSmall
                          ?.copyWith(color: colorScheme.onPrimaryContainer),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: comment.authorUserName,
                            style: textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                            children: [
                              TextSpan(
                                text: ' · ${comment.authorRoleName}',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(comment.body, style: textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Add a comment (optional)',
                    border: OutlineInputBorder(),
                  ),
                  minLines: 1,
                  maxLines: 3,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _onAddComment(revision),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: revision.status == 'Approved'
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                          label: 'Reject', onPressed: () => context.pop()),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: PrimaryButton(
                          label: 'Approve',
                          onPressed: () => _onApprove(revision)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
