import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/pauti_app_bar.dart';
import '../state/donation_flow_notifier.dart';

class DonationReceiptScreen extends ConsumerWidget {
  const DonationReceiptScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final flow = ref.watch(donationFlowProvider);

    final eventName = flow.selectedEvent?['name'] ?? 'Ganesh Utsav 2026';
    final donorName = flow.selectedDonor?['name'] ?? 'Walk-in Donor';
    final donorMobile = flow.selectedDonor?['mobile'] ?? '+91 98220 12345';
    final amount = flow.amount;
    final purpose = flow.purpose;
    final method = flow.paymentMethod;
    final receiptNo = flow.receiptNumber ?? 'REC-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final txnId = flow.paymentId ?? 'TXN-${DateTime.now().millisecondsSinceEpoch}';
    final is80G = flow.is80GRequired;
    final formattedDate = DateFormat('dd MMM yyyy').format(DateTime.now());

    return Scaffold(
      appBar: PautiAppBar(
        title: 'Official Digital Receipt',
        subtitle: 'Step 10 of 10 • Receipt Generated',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Official Printable Receipt Frame Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.deepOrange.shade300, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mandal Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.deepOrange.shade100,
                              child: const Icon(Icons.temple_hindu, color: Colors.deepOrange),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'PAUTI PUSTAK TRUST',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepOrange),
                                ),
                                Text(
                                  'Reg. No: E-12345/MUMBAI • 80G Cert: AAATP1234F',
                                  style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (is80G)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(4)),
                            child: const Text('80G VERIFIED', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10)),
                          ),
                      ],
                    ),
                    const Divider(height: 24, thickness: 1.5),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Receipt No: $receiptNo', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('Date: $formattedDate', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildReceiptField('Received with thanks from', donorName, isBold: true),
                    _buildReceiptField('Contact Number', donorMobile),
                    _buildReceiptField('Event / Festival', eventName),
                    _buildReceiptField('Donation Purpose', purpose),
                    _buildReceiptField('Payment Method', method),
                    _buildReceiptField('Transaction ID', txnId),

                    const SizedBox(height: 16),

                    // Amount Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.deepOrange.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Amount Paid:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(
                            '₹${amount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.deepOrange),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // QR Verification Placeholder & Authorized Signature
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400)),
                              child: const Icon(Icons.qr_code_2, size: 50),
                            ),
                            const SizedBox(height: 4),
                            const Text('Scan to Verify', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Shree Siddhivinayak Mandal',
                              style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            const SizedBox(height: 20),
                            Text('Authorized Signatory', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Download PDF',
                      icon: Icons.download,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Downloading digital PDF receipt...')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: 'Share Receipt',
                      icon: Icons.share,
                      variant: AppButtonVariant.secondary,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sharing digital receipt via WhatsApp...')),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Done (Return to Dashboard)',
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

  Widget _buildReceiptField(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          const Text(': ', style: TextStyle(color: Colors.grey, fontSize: 12)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
