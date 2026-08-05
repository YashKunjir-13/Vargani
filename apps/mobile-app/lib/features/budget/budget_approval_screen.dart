import 'package:flutter/material.dart';

import '../../shared/ui_kit/buttons/primary_button.dart';
import '../../shared/ui_kit/buttons/secondary_button.dart';
import '../../shared/ui_kit/navigation/approval_stepper.dart';
import '../../shared/ui_kit/rows/diff_row.dart';
import 'models/budget_models.dart';

/// A dedicated workflow screen, not a dialog -- multi-level approval needs
/// room for the diff, the comment trail, and the stepper all visible
/// together before a President commits to a decision.
class BudgetApprovalScreen extends StatefulWidget {
  final BudgetApprovalRequest request;
  final List<ApprovalStep> steps;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onReturn;

  const BudgetApprovalScreen({
    super.key,
    required this.request,
    required this.steps,
    this.onApprove,
    this.onReject,
    this.onReturn,
  });

  @override
  State<BudgetApprovalScreen> createState() => _BudgetApprovalScreenState();
}

class _BudgetApprovalScreenState extends State<BudgetApprovalScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Approve Revision ${request.revisionVersion}'),
            Text(
              'Submitted by ${request.submittedBy}',
              style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ApprovalStepper(steps: widget.steps),
          const SizedBox(height: 24),
          Text('What changed', style: textTheme.titleMedium),
          const SizedBox(height: 12),
          for (final change in request.changes) ...[
            Text(
              '${change.fieldLabel} — allocated amount',
              style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            DiffRow(oldValue: change.oldValueLabel, newValue: change.newValueLabel),
            const SizedBox(height: 12),
          ],
          Text(
            'Reason: "${request.reason}"',
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 24),
          Text('Comments', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final comment in request.comments)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      comment.authorName.substring(0, 2).toUpperCase(),
                      style: textTheme.labelSmall?.copyWith(color: colorScheme.onPrimaryContainer),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: comment.authorName,
                            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                            children: [
                              TextSpan(
                                text: ' · ${comment.authorRole}',
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
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              hintText: 'Add a comment (optional)',
              border: OutlineInputBorder(),
            ),
            minLines: 2,
            maxLines: 4,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: SecondaryButton(label: 'Reject', onPressed: widget.onReject),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SecondaryButton(label: 'Return', onPressed: widget.onReturn),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PrimaryButton(label: 'Approve', onPressed: widget.onApprove),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
