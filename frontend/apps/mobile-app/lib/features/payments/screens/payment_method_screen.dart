import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/pauti_app_bar.dart';
import '../state/donation_flow_notifier.dart';

class PaymentMethodScreen extends ConsumerStatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  ConsumerState<PaymentMethodScreen> createState() =>
      _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends ConsumerState<PaymentMethodScreen> {
  String _selectedMethod = 'UPI';

  final List<Map<String, dynamic>> _onlineMethods = [
    {
      'id': 'UPI',
      'title': 'UPI (GPay / PhonePe / Paytm / BHIM)',
      'subtitle': 'Instant digital payment via VPA / QR',
      'icon': Icons.qr_code_2,
    },
    {
      'id': 'CARD',
      'title': 'Credit / Debit Card',
      'subtitle': 'Visa, Mastercard, RuPay Cards',
      'icon': Icons.credit_card,
    },
    {
      'id': 'NET_BANKING',
      'title': 'Net Banking',
      'subtitle': 'All major Indian banks supported',
      'icon': Icons.account_balance,
    },
  ];

  final List<Map<String, dynamic>> _offlineMethods = [
    {
      'id': 'CASH',
      'title': 'Cash Collection',
      'subtitle': 'Direct physical cash received by volunteer',
      'icon': Icons.payments,
    },
    {
      'id': 'CHEQUE',
      'title': 'Cheque / DD',
      'subtitle': 'Bank cheque / demand draft entry',
      'icon': Icons.description,
    },
    {
      'id': 'BANK_TRANSFER',
      'title': 'Direct Bank Transfer / NEFT / RTGS',
      'subtitle': 'Direct transfer to Mandal account',
      'icon': Icons.account_balance_wallet,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedMethod = ref.read(donationFlowProvider).paymentMethod;
  }

  void _proceed() {
    ref.read(donationFlowProvider.notifier).setPaymentMethod(_selectedMethod);
    context.push('/donation/review');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const PautiAppBar(
        title: 'Collect Donation',
        subtitle: 'Step 5 of 10 • Select Payment Method',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Online Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ONLINE PAYMENT',
                      style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: theme.colorScheme.primary)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(4)),
                    child: Text('MOCK GATEWAY ACTIVE',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ..._onlineMethods.map((m) => _buildMethodTile(m)),

              const SizedBox(height: 24),

              // Offline Section Header
              Text('OFFLINE COLLECTION',
                  style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.green.shade800)),
              const SizedBox(height: 10),
              ..._offlineMethods.map((m) => _buildMethodTile(m)),

              const SizedBox(height: 30),
              AppButton(
                label: 'Continue to Review',
                onPressed: _proceed,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodTile(Map<String, dynamic> method) {
    final isSelected = _selectedMethod == method['id'];
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        border: isSelected
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : null,
        onTap: () => setState(() => _selectedMethod = method['id']),
        child: Row(
          children: [
            Radio<String>(
              value: method['id'],
              groupValue: _selectedMethod,
              onChanged: (val) {
                if (val != null) setState(() => _selectedMethod = val);
              },
            ),
            Icon(method['icon'] as IconData,
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.grey.shade700,
                size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method['title'],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(method['subtitle'],
                      style:
                          TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
