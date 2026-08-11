import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/pauti_app_bar.dart';
import '../state/donation_flow_notifier.dart';

class PaymentResultScreen extends ConsumerWidget {
  const PaymentResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(donationFlowProvider);
    final outcome = flow.mockOutcome ?? 'SUCCESS';

    switch (outcome) {
      case 'SUCCESS':
        return _buildSuccessView(context, ref, flow);
      case 'FAILED':
        return _buildFailedView(context, ref, flow);
      case 'CANCELLED':
        return _buildCancelledView(context, ref, flow);
      case 'PENDING':
      default:
        return _buildPendingView(context, ref, flow);
    }
  }

  Widget _buildSuccessView(BuildContext context, WidgetRef ref, DonationFlowState flow) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final formattedDate = dateFormat.format(DateTime.now());

    final eventName = flow.selectedEvent?['name'] ?? 'Ganesh Utsav 2026';
    final donorName = flow.selectedDonor?['name'] ?? 'Walk-in Donor';
    final amount = flow.amount;
    final method = flow.paymentMethod;
    final receiptNo = flow.receiptNumber ?? 'REC-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final txnId = flow.paymentId ?? 'TXN-${DateTime.now().millisecondsSinceEpoch}';

    return Scaffold(
      appBar: PautiAppBar(
        title: 'Donation Confirmation',
        subtitle: 'Step 9 of 10 • Success',
        showBackButton: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 16),
              Text(
                '✓ Donation Successful',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Official collection and receipt recorded in database',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 24),

              AppCard(
                child: Column(
                  children: [
                    _buildRow('Receipt Number', receiptNo, isBold: true),
                    _buildRow('Transaction ID', txnId),
                    _buildRow('Event / Festival', eventName),
                    _buildRow('Donor Name', donorName, isBold: true),
                    _buildRow('Donation Amount', '₹${amount.toStringAsFixed(2)}', isBold: true),
                    _buildRow('Payment Method', method),
                    _buildRow('Date & Time', formattedDate),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              AppButton(
                label: 'View Official Receipt',
                onPressed: () => context.push('/donation/receipt'),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Back to Mandal Dashboard',
                variant: AppButtonVariant.outlined,
                onPressed: () {
                  ref.read(donationFlowProvider.notifier).reset();
                  context.go('/mandal-dashboard');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFailedView(BuildContext context, WidgetRef ref, DonationFlowState flow) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PautiAppBar(
        title: 'Payment Failed',
        subtitle: 'Step 9 of 10 • Failed',
        showBackButton: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 20),
              Text(
                'Payment Failed',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.red.shade800),
              ),
              const SizedBox(height: 10),
              Text(
                flow.errorMessage ?? 'Simulated gateway payment failure. No collection record created.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade800),
              ),
              const SizedBox(height: 32),

              AppButton(
                label: 'Retry Payment',
                onPressed: () async {
                  await ref.read(donationFlowProvider.notifier).retryPayment();
                  if (context.mounted) context.pop();
                },
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Change Payment Method',
                variant: AppButtonVariant.secondary,
                onPressed: () => context.pop(),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Back to Dashboard',
                variant: AppButtonVariant.text,
                onPressed: () {
                  ref.read(donationFlowProvider.notifier).reset();
                  context.go('/mandal-dashboard');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCancelledView(BuildContext context, WidgetRef ref, DonationFlowState flow) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PautiAppBar(
        title: 'Payment Cancelled',
        subtitle: 'Step 9 of 10 • Cancelled',
        showBackButton: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.shade800,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.block, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 20),
              Text(
                'Payment Cancelled',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.orange.shade900),
              ),
              const SizedBox(height: 10),
              Text(
                'User cancelled the payment simulation. No collection record was generated.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade800),
              ),
              const SizedBox(height: 32),

              AppButton(
                label: 'Return to Review',
                onPressed: () => context.pop(),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Back to Dashboard',
                variant: AppButtonVariant.outlined,
                onPressed: () {
                  ref.read(donationFlowProvider.notifier).reset();
                  context.go('/mandal-dashboard');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingView(BuildContext context, WidgetRef ref, DonationFlowState flow) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PautiAppBar(
        title: 'Payment Pending',
        subtitle: 'Step 9 of 10 • Pending',
        showBackButton: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.hourglass_top, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 20),
              Text(
                'Payment Pending Verification',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue.shade900),
              ),
              const SizedBox(height: 10),
              Text(
                'Payment order created. Awaiting bank statement or gateway webhook confirmation.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade800),
              ),
              const SizedBox(height: 32),

              AppButton(
                label: 'Check Payment Status',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Checked status: Payment is PENDING_MATCH')),
                  );
                },
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Back to Mandal Dashboard',
                variant: AppButtonVariant.outlined,
                onPressed: () {
                  ref.read(donationFlowProvider.notifier).reset();
                  context.go('/mandal-dashboard');
                },
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
