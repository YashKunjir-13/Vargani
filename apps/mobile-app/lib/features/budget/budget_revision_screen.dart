import 'package:flutter/material.dart';

import '../../shared/ui_kit/buttons/primary_button.dart';
import '../../shared/ui_kit/buttons/secondary_button.dart';
import '../../shared/ui_kit/chips/status_chip.dart';
import 'models/budget_models.dart';

/// Creating a revision never edits the active budget in place -- it drafts
/// a new version that only takes effect after approval, so the Active
/// budget stays trustworthy for anyone viewing it mid-review.
class BudgetRevisionScreen extends StatefulWidget {
  final String nextVersionLabel;
  final String initialReason;
  final List<RevisionAdjustment> adjustments;
  final bool netChangeBalances;
  final VoidCallback? onSaveDraft;
  final VoidCallback? onSubmitForApproval;

  const BudgetRevisionScreen({
    super.key,
    required this.nextVersionLabel,
    this.initialReason = '',
    required this.adjustments,
    required this.netChangeBalances,
    this.onSaveDraft,
    this.onSubmitForApproval,
  });

  @override
  State<BudgetRevisionScreen> createState() => _BudgetRevisionScreenState();
}

class _BudgetRevisionScreenState extends State<BudgetRevisionScreen> {
  late final _reasonController = TextEditingController(text: widget.initialReason);

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

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
            Text('New Revision — ${widget.nextVersionLabel}'),
            Text('Draft', style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Reason for revision', style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
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
                for (final adjustment in widget.adjustments)
                  ListTile(
                    title: Text(adjustment.categoryName, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                    subtitle: Text('Current ${adjustment.currentAllocationLabel}'),
                    trailing: Text(
                      adjustment.proposedAllocationLabel,
                      style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.netChangeBalances ? colorScheme.tertiaryContainer : colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.netChangeBalances ? 'Net change balances to zero' : 'Net change does not balance',
                  style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                StatusChip(
                  label: widget.netChangeBalances ? '₹0' : 'Unbalanced',
                  type: widget.netChangeBalances ? StatusChipType.success : StatusChipType.error,
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
              Expanded(child: SecondaryButton(label: 'Save Draft', onPressed: widget.onSaveDraft)),
              const SizedBox(width: 8),
              Expanded(child: PrimaryButton(label: 'Submit for Approval', onPressed: widget.onSubmitForApproval)),
            ],
          ),
        ),
      ),
    );
  }
}
