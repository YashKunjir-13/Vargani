import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/pauti_app_bar.dart';
import '../state/donation_flow_notifier.dart';

class MockPaymentScreen extends ConsumerWidget {
  const MockPaymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final flow = ref.watch(donationFlowProvider);

    final amount = flow.amount;
    final method = flow.paymentMethod;
    final paymentId = flow.paymentId ?? 'pay_mock_1001';
    final razorpayOrderId = flow.razorpayOrderId ?? 'order_mock_1001';

    Future<void> triggerOutcome(String outcome, {String? reason}) async {
      final success = await ref
          .read(donationFlowProvider.notifier)
          .processMockOutcome(outcome, reason: reason);
      if (!context.mounted) return;
      if (success) {
        context.pushReplacement('/donation/result');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                flow.errorMessage ?? 'Failed to process mock payment outcome.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: const PautiAppBar(
        title: 'Mock Payment Gateway',
        subtitle: 'Step 8 of 10 • Presentation Simulator',
        showBackButton: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Presentation Mode Header Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade800,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.developer_mode,
                            color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'DEMO / PRESENTATION PAYMENT GATEWAY',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Simulating Razorpay / Gateway provider interface without charging real money.',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Mock Checkout Modal Card
              AppCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lock,
                                color: theme.colorScheme.primary, size: 24),
                            const SizedBox(width: 8),
                            const Text('Pauti Pustak Gateway',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        Text('INR ₹${amount.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: theme.colorScheme.primary)),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildDetailRow('Payment Order ID', razorpayOrderId),
                    _buildDetailRow('Internal Payment ID', paymentId),
                    _buildDetailRow('Selected Method', method),
                    _buildDetailRow('Status', 'Awaiting Action',
                        isHighlighted: true),
                    const SizedBox(height: 20),

                    Text('Select Simulated Gateway Outcome:',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 14),

                    // 1. Success
                    AppButton(
                      label: '✓ Simulate SUCCESS',
                      variant: AppButtonVariant.primary,
                      isLoading: flow.isLoading,
                      onPressed: flow.isLoading
                          ? null
                          : () => triggerOutcome('SUCCESS'),
                    ),
                    const SizedBox(height: 10),

                    // 2. Failure
                    AppButton(
                      label: '✕ Simulate FAILURE',
                      variant: AppButtonVariant.danger,
                      isLoading: flow.isLoading,
                      onPressed: flow.isLoading
                          ? null
                          : () => triggerOutcome('FAILED',
                              reason:
                                  'Insufficient funds / Bank server timeout'),
                    ),
                    const SizedBox(height: 10),

                    // 3. Cancelled
                    AppButton(
                      label: '⊘ Simulate CANCEL',
                      variant: AppButtonVariant.secondary,
                      isLoading: flow.isLoading,
                      onPressed: flow.isLoading
                          ? null
                          : () => triggerOutcome('CANCELLED',
                              reason: 'User cancelled on checkout page'),
                    ),
                    const SizedBox(height: 10),

                    // 4. Pending
                    AppButton(
                      label: '⏳ Simulate PENDING',
                      variant: AppButtonVariant.outlined,
                      isLoading: flow.isLoading,
                      onPressed: flow.isLoading
                          ? null
                          : () => triggerOutcome('PENDING'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
              fontSize: 12,
              color: isHighlighted ? Colors.orange.shade800 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
