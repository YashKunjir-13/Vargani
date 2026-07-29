import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_image_picker.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/pauti_app_bar.dart';
import '../models/bill.dart';
import '../state/bills_notifier.dart';

class CreateBillScreen extends ConsumerStatefulWidget {
  const CreateBillScreen({super.key});

  @override
  ConsumerState<CreateBillScreen> createState() => _CreateBillScreenState();
}

class _CreateBillScreenState extends ConsumerState<CreateBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _receiverController = TextEditingController();
  final _amountController = TextEditingController();
  final _taskController = TextEditingController();
  final _contactController = TextEditingController();

  bool _isRegisteredVendor = false;
  String? _billImagePath;
  bool _isOcrProcessed = false;

  @override
  void dispose() {
    _receiverController.dispose();
    _amountController.dispose();
    _taskController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _runSimulatedOcr() {
    setState(() {
      _billImagePath = 'bill_scan_receipt_2026.jpg';
      _isOcrProcessed = true;
      _receiverController.text = 'Ganesh Electricals & Sound Systems';
      _amountController.text = '12500';
      _taskController.text = 'Pandal Lighting, Sound & Generator Setup';
      _contactController.text = '+91 98220 11223';
      _isRegisteredVendor = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OCR scanned! Extracted vendor name, amount (₹12,500), and task description.'),
        backgroundColor: Colors.indigo,
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    final bill = ref.read(billsProvider.notifier).create(
          receiverName: _receiverController.text.trim(),
          amount: amount,
          taskOrField: _taskController.text.trim(),
          contact: _contactController.text.trim().isEmpty ? null : _contactController.text.trim(),
          isRegisteredVendor: _isRegisteredVendor,
          createdBy: 'Volunteer User',
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bill drafted: ${bill.billNumber} (${bill.status.label})'),
        backgroundColor: Colors.green,
      ),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PautiAppBar(
        title: L10n.tr(ref, 'bill_generation'),
        subtitle: 'Treasurer Portal',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bill Photo Attach & OCR Step
              AppImagePicker(
                label: 'Attach Bill Photo & Auto-Extract OCR',
                imagePath: _billImagePath,
                hintText: 'Tap to attach bill photo for AI OCR prefill',
                icon: Icons.document_scanner_outlined,
                onPickImage: _runSimulatedOcr,
                onRemoveImage: () {
                  setState(() {
                    _billImagePath = null;
                    _isOcrProcessed = false;
                  });
                },
              ),
              const SizedBox(height: 16),

              if (_isOcrProcessed) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade400),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.amber),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'OCR Review Step: Form pre-filled from scanned invoice. Please review fields below before saving.',
                          style: TextStyle(color: Colors.amber.shade900, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              AppCard(
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Registered Vendor'),
                  subtitle: const Text('Off = ad-hoc receiver by name/contact only'),
                  value: _isRegisteredVendor,
                  onChanged: (v) => setState(() => _isRegisteredVendor = v),
                ),
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'Receiver / Vendor Name *',
                controller: _receiverController,
                prefixIcon: Icons.storefront_outlined,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Receiver name is required' : null,
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'Amount (₹) *',
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.currency_rupee,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Amount is required' : null,
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'Task / Event Expense Field *',
                controller: _taskController,
                prefixIcon: Icons.assignment_outlined,
                hintText: 'e.g. Stage Decor, Sound System, Prasadam',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Task/Field description is required' : null,
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: L10n.tr(ref, 'contact'),
                isOptional: true,
                controller: _contactController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
              ),
              const SizedBox(height: 28),

              AppButton(
                label: 'Save Bill as Draft',
                icon: Icons.save_outlined,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
