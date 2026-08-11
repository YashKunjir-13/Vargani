import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/pauti_app_bar.dart';
import '../state/donation_flow_notifier.dart';

class DonationAmountScreen extends ConsumerStatefulWidget {
  const DonationAmountScreen({super.key});

  @override
  ConsumerState<DonationAmountScreen> createState() => _DonationAmountScreenState();
}

class _DonationAmountScreenState extends ConsumerState<DonationAmountScreen> {
  final _amountCtrl = TextEditingController(text: '1000');
  double _selectedAmount = 1000.0;
  String? _errorText;

  final List<double> _quickAmounts = [500, 1000, 2500, 5000, 10000];

  @override
  void initState() {
    super.initState();
    final current = ref.read(donationFlowProvider).amount;
    _selectedAmount = current;
    _amountCtrl.text = current.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _onQuickSelect(double amt) {
    setState(() {
      _selectedAmount = amt;
      _amountCtrl.text = amt.toStringAsFixed(0);
      _errorText = null;
    });
  }

  void _onAmountChanged(String val) {
    final parsed = double.tryParse(val.trim());
    if (parsed == null || parsed <= 0) {
      setState(() {
        _selectedAmount = 0.0;
        _errorText = 'Enter a valid positive donation amount';
      });
    } else {
      setState(() {
        _selectedAmount = parsed;
        _errorText = null;
      });
    }
  }

  void _proceed() {
    if (_selectedAmount <= 0 || _errorText != null) {
      setState(() => _errorText = 'Please enter a valid positive amount.');
      return;
    }
    ref.read(donationFlowProvider.notifier).setAmount(_selectedAmount);
    context.push('/donation/details');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventName = ref.watch(donationFlowProvider).selectedEvent?['name'] ?? 'Ganesh Utsav 2026';
    final donorName = ref.watch(donationFlowProvider).selectedDonor?['name'] ?? 'Donor';

    return Scaffold(
      appBar: PautiAppBar(
        title: 'Collect Donation',
        subtitle: 'Step 3 of 10 • Enter Amount',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Banner
              AppCard(
                color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                child: Row(
                  children: [
                    const Icon(Icons.event, color: Colors.deepOrange),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(eventName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('Donor: $donorName', style: TextStyle(color: Colors.grey.shade800, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text('Donation Amount', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // Large Input Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _errorText != null ? Colors.red : theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Text('₹', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _amountCtrl,
                        keyboardType: TextInputType.number,
                        style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                        ),
                        onChanged: _onAmountChanged,
                      ),
                    ),
                  ],
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 6),
                Text(_errorText!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],
              const SizedBox(height: 20),

              Text('Quick Select', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _quickAmounts.map((amt) {
                  final isSelected = _selectedAmount == amt;
                  return ChoiceChip(
                    label: Text('₹${amt.toStringAsFixed(0)}'),
                    selected: isSelected,
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (_) => _onQuickSelect(amt),
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              // Breakdown Card
              AppCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Donation Amount'),
                        Text('₹${_selectedAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Platform / Gateway Fee'),
                        Text('₹0.00 (Waived)', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Payable', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        Text(
                          '₹${_selectedAmount.toStringAsFixed(2)}',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              AppButton(
                label: 'Continue to Details',
                onPressed: _proceed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
