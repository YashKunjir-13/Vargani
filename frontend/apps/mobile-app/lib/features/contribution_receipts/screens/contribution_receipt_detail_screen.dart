import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../core/permissions/permission_guard.dart';
import '../../../core/permissions/user_role.dart';
import '../../../shared/utils/pdf_generator.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/pauti_app_bar.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../templates/state/templates_notifier.dart';
import '../models/contribution_receipt.dart';
import '../state/contribution_receipts_notifier.dart';

class ContributionReceiptDetailScreen extends ConsumerWidget {
  final String receiptId;

  const ContributionReceiptDetailScreen({super.key, required this.receiptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receipts = ref.watch(contributionReceiptsProvider);
    final activeTemplate = ref.watch(activeTemplateProvider);
    final permissions = ref.watch(permissionsProvider);
    final theme = Theme.of(context);

    final receipt = receipts.where((r) => r.id == receiptId).firstOrNull;
    final dateFormat = DateFormat('d MMMM yyyy, h:mm a');

    if (receipt == null) {
      return const Scaffold(
        appBar: PautiAppBar(
            title: 'Contribution Receipt',
            subtitle: 'Contributor Portal',
            showBackButton: true),
        body: Center(child: Text('Contribution receipt not found')),
      );
    }

    return Scaffold(
      appBar: PautiAppBar(
        title: receipt.contributionReceiptNumber,
        subtitle: 'Contributor Portal',
        showBackButton: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Active Template Branding Header Preview Card
          AppCard(
            color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Branding: ${activeTemplate.name}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    StatusChip(label: receipt.status.label),
                  ],
                ),
                const SizedBox(height: 16),
                Icon(Icons.volunteer_activism,
                    size: 44, color: theme.colorScheme.secondary),
                const SizedBox(height: 6),
                Text(
                  receipt.mandalName,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'OFFICIAL NON-MONETARY CONTRIBUTION PAUTI RECEIPT',
                  style: theme.textTheme.bodySmall?.copyWith(
                      letterSpacing: 1.1, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Text(
                  receipt.donationType,
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Receipt Information Breakdown
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Receipt Breakdown',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Divider(height: 24),
                _InfoRow(
                    label: 'CRCPT Number',
                    value: receipt.contributionReceiptNumber),
                _InfoRow(
                    label: 'Contributor Name', value: receipt.contributorName),
                _InfoRow(
                    label: 'Donation Category', value: receipt.donationType),
                _InfoRow(
                    label: 'Issued Date',
                    value: dateFormat.format(receipt.issuedDate)),
                _InfoRow(
                    label: 'Linked Contribution ID',
                    value: receipt.contributionId),
                _InfoRow(
                    label: 'Active Mandal Template',
                    value: activeTemplate.name),
                if (receipt.voidReason != null)
                  _InfoRow(
                      label: 'Void Reason',
                      value: receipt.voidReason!,
                      isDanger: true),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // WhatsApp Delivery Details
          AppCard(
            child: Row(
              children: [
                const Icon(Icons.chat_outlined, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WhatsApp Delivery Status',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Status: ${receipt.whatsappDeliveryStatus.label} ${receipt.whatsappRetryCount > 0 ? "(${receipt.whatsappRetryCount} retries)" : ""}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref
                        .read(contributionReceiptsProvider.notifier)
                        .resendWhatsapp(receipt.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'WhatsApp resend request queued successfully.')),
                    );
                  },
                  child: const Text('Resend'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Re-Download PDF Action Button
          AppButton(
            label: 'Re-Download Contribution PDF',
            icon: Icons.picture_as_pdf,
            onPressed: () {
              Printing.layoutPdf(
                onLayout: (format) async {
                  return PdfReceiptGenerator.generateReceiptPdf(
                    receiptNumber: receipt.contributionReceiptNumber,
                    mandalName: receipt.mandalName,
                    donorName: receipt.contributorName,
                    amountText: receipt.donationType,
                    dateText: dateFormat.format(receipt.issuedDate),
                    typeLabel: 'Non-Monetary Contribution',
                  );
                },
              );
            },
          ),
          const SizedBox(height: 12),

          // Permission Gated Void Action
          if (receipt.status != ContributionReceiptStatus.voided)
            PermissionGuard(
              hasPermission: permissions.canVoidPayment,
              fallbackTooltip:
                  'Auditor or Admin role required to void contribution receipt',
              child: AppButton(
                label: 'Void Contribution Receipt',
                variant: AppButtonVariant.danger,
                icon: Icons.block,
                onPressed: () => _showVoidDialog(context, ref, receipt),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showVoidDialog(
      BuildContext context, WidgetRef ref, ContributionReceipt receipt) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Void Contribution Receipt'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
              labelText: 'Reason for voiding (mandatory)'),
          maxLines: 2,
        ),
        actions: [
          TextButton(
              onPressed: () => context.pop(), child: const Text('Cancel')),
          FilledButton(
              onPressed: () => context.pop(controller.text.trim()),
              child: const Text('Confirm Void')),
        ],
      ),
    );

    if (reason != null && reason.isNotEmpty) {
      ref
          .read(contributionReceiptsProvider.notifier)
          .voidReceipt(receipt.id, reason: reason);
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
