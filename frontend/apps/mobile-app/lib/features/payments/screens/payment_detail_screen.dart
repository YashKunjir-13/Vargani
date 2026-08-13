import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/permissions/permission_guard.dart';
import '../../../core/permissions/user_role.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/pauti_app_bar.dart';
import '../../../shared/widgets/status_chip.dart';
import '../models/payment.dart';
import '../state/payments_notifier.dart';

class PaymentDetailScreen extends ConsumerWidget {
  final String paymentId;

  const PaymentDetailScreen({super.key, required this.paymentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPayments = ref.watch(paymentsProvider);
    final permissions = ref.watch(permissionsProvider);
    final theme = Theme.of(context);
    final currency =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final dateFormat = DateFormat('d MMMM yyyy, h:mm a');

    return Scaffold(
      appBar: const PautiAppBar(
        title: 'Payment Details',
        subtitle: 'Treasurer Portal',
        showBackButton: true,
      ),
      body: asyncPayments.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text('Failed to load payment details: $err')),
        data: (payments) {
          final payment = payments.firstWhere(
            (p) => p.id == paymentId,
            orElse: () => Payment(
              id: paymentId,
              donorName: 'Unknown',
              amount: 0,
              paymentDateTime: DateTime.now(),
              channel: PaymentChannel.qrCode,
              status: PaymentStatus.voided,
            ),
          );

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Header Card
              AppCard(
                color:
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          payment.id,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        StatusChip(label: payment.status.label),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currency.format(payment.amount),
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      payment.donorName,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Channel: ${payment.channel.label}',
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
                      'Transaction Information',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 24),
                    _DetailRow(
                        icon: Icons.person_outline,
                        label: 'Donor Name',
                        value: payment.donorName),
                    _DetailRow(
                      icon: Icons.location_on_outlined,
                      label: 'Address',
                      value: payment.address ?? 'Not provided (Optional)',
                      isMuted: payment.address == null,
                    ),
                    _DetailRow(
                      icon: Icons.phone_outlined,
                      label: 'Contact',
                      value: payment.contact ?? 'Not provided (Optional)',
                      isMuted: payment.contact == null,
                    ),
                    _DetailRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Date & Time',
                      value: dateFormat.format(payment.paymentDateTime),
                    ),
                    _DetailRow(
                      icon: Icons.badge_outlined,
                      label: 'Collected By',
                      value: payment.collectedBy ?? 'Direct System Record',
                    ),
                    if (payment.matchedBy != null)
                      _DetailRow(
                        icon: Icons.verified_outlined,
                        label: 'Matched & Verified By',
                        value: payment.matchedBy!,
                      ),
                    if (payment.voidReason != null)
                      _DetailRow(
                        icon: Icons.warning_amber_outlined,
                        label: 'Void Reason',
                        value: payment.voidReason!,
                        isDanger: true,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Actions
              if (payment.status == PaymentStatus.pendingMatch) ...[
                PermissionGuard(
                  hasPermission: permissions.canConfirmPaymentMatch,
                  fallbackTooltip:
                      'Collector, Auditor or Admin role required to confirm QR match',
                  child: AppButton(
                    label: L10n.tr(ref, 'confirm_match'),
                    icon: Icons.check_circle,
                    onPressed: () async {
                      final ok = await ref
                          .read(paymentsProvider.notifier)
                          .confirmMatch(
                            payment.id,
                            matchedBy:
                                'Active User (${permissions.role.label})',
                          );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ok
                                ? 'Payment match confirmed in database! Receipt generated.'
                                : 'Failed to confirm payment match.'),
                            backgroundColor: ok ? Colors.green : Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],

              if (payment.status != PaymentStatus.voided) ...[
                PermissionGuard(
                  hasPermission: permissions.canVoidPayment,
                  fallbackTooltip:
                      'Auditor or Admin role required to void payment',
                  child: AppButton(
                    label: L10n.tr(ref, 'void'),
                    variant: AppButtonVariant.danger,
                    icon: Icons.block,
                    onPressed: () async {
                      final ok =
                          await ref.read(paymentsProvider.notifier).void_(
                                payment.id,
                                reason: 'Voided by ${permissions.role.label}',
                              );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ok
                                ? 'Payment has been voided in database.'
                                : 'Failed to void payment.'),
                            backgroundColor: ok ? Colors.orange : Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],

              AppButton(
                label: 'Back to List',
                variant: AppButtonVariant.outlined,
                onPressed: () => context.pop(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isMuted;
  final bool isDanger;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isMuted = false,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: isDanger
                ? Colors.red
                : isMuted
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDanger
                        ? Colors.red
                        : isMuted
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
