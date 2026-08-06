import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/permissions/permission_guard.dart';
import '../../../core/permissions/user_role.dart';
import '../../../core/session/session_controller.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/pauti_app_bar.dart';
import '../../../shared/widgets/status_chip.dart';
import '../models/bill.dart';
import '../state/bills_notifier.dart';

class BillDetailScreen extends ConsumerWidget {
  final String billId;

  const BillDetailScreen({super.key, required this.billId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bills = ref.watch(billsProvider);
    final permissions = ref.watch(permissionsProvider);
    final theme = Theme.of(context);

    final bill = bills.where((b) => b.id == billId).firstOrNull;
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final dateFormat = DateFormat('d MMMM yyyy');

    if (bill == null) {
      return const Scaffold(
        appBar: PautiAppBar(title: 'Bill Details', subtitle: 'Mandal Management', showBackButton: true),
        body: Center(child: Text('Bill not found')),
      );
    }

    return Scaffold(
      appBar: PautiAppBar(
        title: bill.billNumber,
        subtitle: 'Mandal Management',
        showBackButton: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Top Header Card
          AppCard(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      bill.billNumber,
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    StatusChip(label: bill.status.label),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  currency.format(bill.amount),
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bill.receiverName,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Task: ${bill.taskOrField}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Detail Section
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bill Specifications',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Divider(height: 24),
                _InfoRow(label: 'Receiver / Vendor', value: bill.receiverName + (bill.isRegisteredVendor ? ' (Registered)' : ' (Ad-hoc)')),
                _InfoRow(label: 'Expense Field', value: bill.taskOrField),
                _InfoRow(label: 'Invoice Date', value: dateFormat.format(bill.date)),
                if (bill.contact != null) _InfoRow(label: 'Contact', value: bill.contact!),
                _InfoRow(label: 'Created By', value: bill.createdBy),
                if (bill.approvedBy != null) _InfoRow(label: 'Approved By', value: bill.approvedBy!),
                if (bill.paymentMode != null) _InfoRow(label: 'Disbursement Mode', value: bill.paymentMode!.label),
                if (bill.rejectionReason != null) _InfoRow(label: 'Last Rejection', value: bill.rejectionReason!, isDanger: true),
                if (bill.cancelReason != null) _InfoRow(label: 'Cancel Reason', value: bill.cancelReason!, isDanger: true),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Workflow Action Buttons Gated by User Role
          ..._buildWorkflowActions(context, ref, bill, permissions),
        ],
      ),
    );
  }

  List<Widget> _buildWorkflowActions(BuildContext context, WidgetRef ref, Bill bill, AppPermissions permissions) {
    final notifier = ref.read(billsProvider.notifier);
    final sessionUser = ref.watch(sessionControllerProvider).user;
    final currentUserId = sessionUser?.id ?? sessionUser?.displayName ?? 'user-president-2';
    final actions = <Widget>[];

    // 1. Submit for Approval (Collector / Auditor / Admin)
    if (bill.status == BillStatus.draft) {
      actions.add(
        PermissionGuard(
          hasPermission: permissions.canSubmitBill,
          fallbackTooltip: 'Collector, Auditor or Admin role required to submit bill',
          child: AppButton(
            label: 'Submit Bill for Approval',
            icon: Icons.send_outlined,
            onPressed: () {
              notifier.submit(bill.id);
              _snack(context, 'Submitted for approval successfully');
            },
          ),
        ),
      );
    }

    // 2. Approve or Reject (Auditor / Admin)
    if (bill.status == BillStatus.pendingApproval) {
      actions.add(
        PermissionGuard(
          hasPermission: permissions.canApproveRejectBill,
          fallbackTooltip: 'Auditor or Admin role required to approve/reject bills',
          child: Column(
            children: [
              AppButton(
                label: L10n.tr(ref, 'approve'),
                icon: Icons.check_circle_outline,
                onPressed: () {
                  try {
                    notifier.approve(bill.id, approvedBy: currentUserId);
                    _snack(context, 'Bill approved successfully');
                  } on SelfApprovalException catch (e) {
                    _snack(context, e.message, isError: true);
                  }
                },
              ),
              const SizedBox(height: 12),
              AppButton(
                label: L10n.tr(ref, 'reject'),
                variant: AppButtonVariant.outlined,
                icon: Icons.close,
                onPressed: () => _showReasonDialog(
                  context,
                  title: 'Reject Bill',
                  onSubmit: (reason) {
                    notifier.reject(bill.id, reason: reason);
                    _snack(context, 'Bill rejected and returned to draft');
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Mark as Paid (Admin only)
    if (bill.status == BillStatus.approved) {
      actions.add(
        PermissionGuard(
          hasPermission: permissions.canMarkBillPaid,
          fallbackTooltip: 'Admin role required to disburse funds & mark paid',
          child: AppButton(
            label: L10n.tr(ref, 'mark_paid'),
            icon: Icons.payments_outlined,
            onPressed: () => _showMarkPaidDialog(context, notifier, bill.id),
          ),
        ),
      );
    }

    if (actions.isNotEmpty) {
      actions.add(const SizedBox(height: 12));
    }

    actions.add(
      AppButton(
        label: 'Back to List',
        variant: AppButtonVariant.outlined,
        onPressed: () => context.pop(),
      ),
    );

    return actions;
  }

  void _snack(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? Colors.red.shade700 : null),
    );
  }

  Future<void> _showReasonDialog(
    BuildContext context, {
    required String title,
    required void Function(String reason) onSubmit,
  }) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Reason (mandatory)'),
          maxLines: 2,
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
          FilledButton(onPressed: () => context.pop(controller.text.trim()), child: const Text('Confirm')),
        ],
      ),
    );
    if (reason != null && reason.isNotEmpty) onSubmit(reason);
  }

  Future<void> _showMarkPaidDialog(BuildContext context, BillsNotifier notifier, String billId) async {
    final mode = await showDialog<BillPaymentMode>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Disbursement Mode'),
        children: BillPaymentMode.values
            .map((m) => SimpleDialogOption(
                  onPressed: () => context.pop(m),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(m.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ))
            .toList(),
      ),
    );
    if (mode != null) {
      notifier.markPaid(billId, paymentMode: mode);
      if (context.mounted) _snack(context, 'Marked Paid via ${mode.label}');
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDanger;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDanger ? Colors.red : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
