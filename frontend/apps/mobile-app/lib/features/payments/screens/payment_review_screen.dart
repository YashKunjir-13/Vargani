import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/pauti_app_bar.dart';
import '../state/donation_flow_notifier.dart';

class PaymentReviewScreen extends ConsumerWidget {
  const PaymentReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final flow = ref.watch(donationFlowProvider);

    final eventName = flow.selectedEvent?['name'] ?? flow.selectedEvent?['title'] ?? 'Ganesh Utsav 2026';
    final donorName = flow.selectedDonor?['name'] ?? 'Donor';
    final donorMobile = flow.selectedDonor?['mobile'] ?? 'N/A';
    final amount = flow.amount;
    final purpose = flow.purpose;
    final method = flow.paymentMethod;
    final is80G = flow.is80GRequired;

    Future<void> onConfirm() async {
      final success = await ref.read(donationFlowProvider.notifier).createPaymentOrder();
      if (!context.mounted) return;
      if (success) {
        if (method == 'CASH' || method == 'CHEQUE' || method == 'BANK_TRANSFER') {
          // Offline payment completes immediately
          context.push('/donation/result');
        } else {
          // Online mock payment goes to processing loader
          context.push('/donation/processing');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(flow.errorMessage ?? 'Payment creation failed. Please retry.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    return Scaffold(
      appBar: const PautiAppBar(
        title: 'Collect Donation',
        subtitle: 'Step 6 of 10 • Review Donation',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event & Donor Card
              AppCard(
                child: Column(
                  children: [
                    _buildRow('Event / Festival', eventName, isBold: true),
                    const Divider(height: 16),
                    _buildRow('Donor Name', donorName, isBold: true),
                    _buildRow('Contact', donorMobile),
                    _buildRow('Purpose', purpose),
                    _buildRow('80G Certificate', is80G ? 'Yes Required' : 'No'),
                    _buildRow('Payment Method', method, isBold: true),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Total Payable Box
              AppCard(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Amount Payable', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      '₹${amount.toStringAsFixed(2)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    'Protected by Idempotency Key: ${flow.idempotencyKey?.substring(0, 14)}...',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              AppButton(
                label: 'Confirm & Pay ₹${amount.toStringAsFixed(0)}',
                isLoading: flow.isLoading,
                onPressed: flow.isLoading ? null : onConfirm,
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Edit Details',
                variant: AppButtonVariant.outlined,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
