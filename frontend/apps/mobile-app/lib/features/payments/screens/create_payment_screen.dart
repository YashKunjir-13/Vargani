import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/pauti_app_bar.dart';
import '../models/payment.dart';
import '../state/payments_notifier.dart';

class CreatePaymentScreen extends ConsumerStatefulWidget {
  const CreatePaymentScreen({super.key});

  @override
  ConsumerState<CreatePaymentScreen> createState() =>
      _CreatePaymentScreenState();
}

class _CreatePaymentScreenState extends ConsumerState<CreatePaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _donorNameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();

  PaymentChannel _channel = PaymentChannel.qrCode;
  DateTime _paymentDateTime = DateTime.now();

  @override
  void dispose() {
    _donorNameCtrl.dispose();
    _amountCtrl.dispose();
    _addressCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid positive amount.')),
      );
      return;
    }

    final payment = await ref.read(paymentsProvider.notifier).create(
          donorName: _donorNameCtrl.text.trim(),
          amount: amount,
          address: _addressCtrl.text.trim().isEmpty
              ? null
              : _addressCtrl.text.trim(),
          contact: _contactCtrl.text.trim().isEmpty
              ? null
              : _contactCtrl.text.trim(),
          channel: _channel,
        );

    if (!mounted) return;

    if (payment != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Payment recorded in database with status: ${payment.status.label}'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to record payment in database.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('d MMM yyyy, h:mm a');

    return Scaffold(
      appBar: PautiAppBar(
        title: L10n.tr(ref, 'record_payment'),
        subtitle: 'Donation Collection',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Channel',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    SegmentedButton<PaymentChannel>(
                      segments: const [
                        ButtonSegment(
                          value: PaymentChannel.qrCode,
                          icon: Icon(Icons.qr_code_2),
                          label: Text('QR / UPI Entry'),
                        ),
                        ButtonSegment(
                          value: PaymentChannel.inApp,
                          icon: Icon(Icons.phone_android),
                          label: Text('In-App Collection'),
                        ),
                      ],
                      selected: {_channel},
                      onSelectionChanged: (val) {
                        setState(() => _channel = val.first);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Form Inputs
              AppTextField(
                label: L10n.tr(ref, 'donor_name'),
                controller: _donorNameCtrl,
                prefixIcon: Icons.person_outline,
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Donor name is required'
                    : null,
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: L10n.tr(ref, 'amount'),
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.currency_rupee,
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Amount is required'
                    : null,
              ),
              const SizedBox(height: 16),

              // Date & Time Picker
              AppTextField(
                label: 'Payment Date & Time',
                readOnly: true,
                prefixIcon: Icons.calendar_today_outlined,
                controller: TextEditingController(
                    text: dateFormat.format(_paymentDateTime)),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _paymentDateTime,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (pickedDate != null && context.mounted) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_paymentDateTime),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _paymentDateTime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 16),

              // OPTIONAL FIELDS - Visibly Tagged
              AppTextField(
                label: L10n.tr(ref, 'address'),
                isOptional: true,
                controller: _addressCtrl,
                prefixIcon: Icons.location_on_outlined,
                maxLines: 2,
                hintText: 'Building, Street, Landmark',
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: L10n.tr(ref, 'contact'),
                isOptional: true,
                controller: _contactCtrl,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                hintText: '+91 98765 43210',
              ),
              const SizedBox(height: 28),

              AppButton(
                label: L10n.tr(ref, 'submit'),
                icon: Icons.check_circle_outline,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
