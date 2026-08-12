import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/pauti_app_bar.dart';
import '../state/donation_flow_notifier.dart';

class DonationDetailsScreen extends ConsumerStatefulWidget {
  const DonationDetailsScreen({super.key});

  @override
  ConsumerState<DonationDetailsScreen> createState() => _DonationDetailsScreenState();
}

class _DonationDetailsScreenState extends ConsumerState<DonationDetailsScreen> {
  final _purposeCtrl = TextEditingController(text: 'Ganesh Festival Vargani');
  final _notesCtrl = TextEditingController();
  bool _is80GRequired = false;

  final List<String> _purposes = [
    'Ganesh Festival Vargani',
    'Aarti Sponsorship',
    'Maha Prasad Contribution',
    'Decorations & Lighting',
    'General Festival Fund',
  ];

  @override
  void initState() {
    super.initState();
    final flow = ref.read(donationFlowProvider);
    _purposeCtrl.text = flow.purpose;
    _is80GRequired = flow.is80GRequired;
    _notesCtrl.text = flow.notes;
  }

  @override
  void dispose() {
    _purposeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _proceed() {
    ref.read(donationFlowProvider.notifier).setDetails(
          purpose: _purposeCtrl.text.trim(),
          is80GRequired: _is80GRequired,
          notes: _notesCtrl.text.trim(),
        );
    context.push('/donation/payment-method');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final flow = ref.watch(donationFlowProvider);
    final donorName = flow.selectedDonor?['name'] ?? 'Donor';
    final amount = flow.amount;

    return Scaffold(
      appBar: const PautiAppBar(
        title: 'Collect Donation',
        subtitle: 'Step 4 of 10 • Donation Details',
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Donor: $donorName', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('Amount: ₹${amount.toStringAsFixed(2)}', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Icon(Icons.description, color: Colors.deepOrange),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text('Donation Purpose', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _purposes.contains(_purposeCtrl.text) ? _purposeCtrl.text : _purposes.first,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: _purposes.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _purposeCtrl.text = val);
                },
              ),
              const SizedBox(height: 20),

              // 80G Tax Exemption Switch
              AppCard(
                child: SwitchListTile(
                  title: const Text('Require 80G Tax Exemption Certificate?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Generates official 80G receipt for tax deduction.'),
                  value: _is80GRequired,
                  activeThumbColor: theme.colorScheme.primary,
                  onChanged: (val) => setState(() => _is80GRequired = val),
                ),
              ),
              const SizedBox(height: 20),

              AppTextField(
                controller: _notesCtrl,
                label: 'Special Notes / Dedicated To',
                hintText: 'e.g. In memory of late Shri S. Deshmukh',
                maxLines: 3,
              ),

              const SizedBox(height: 30),
              AppButton(
                label: 'Continue to Payment Method',
                onPressed: _proceed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
