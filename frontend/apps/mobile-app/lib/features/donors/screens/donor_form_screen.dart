import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../core/core.dart';
import '../../../shared/shared.dart';
import '../../../shared/utils/pdf_generator.dart';
import '../../authentication/presentation/widgets/auth_design_tokens.dart';
import '../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../payments/state/payments_notifier.dart';
import '../../receipts/state/receipts_notifier.dart';
import '../models/donor.dart';
import '../providers/donor_providers.dart';

class DonorFormScreen extends ConsumerStatefulWidget {
  const DonorFormScreen({super.key, this.donorId});

  final String? donorId;

  @override
  ConsumerState<DonorFormScreen> createState() => _DonorFormScreenState();
}

class _DonorFormScreenState extends ConsumerState<DonorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _amountController = TextEditingController();
  final _purposeController = TextEditingController(text: 'Ganpati Utsav 2026');

  bool _addDonationNow = false;
  String _selectedPaymentMethod = 'Cash';
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _amountController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final donorId = widget.donorId;
    if (donorId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final donor = ref.read(donorDetailProvider(donorId)).value;
        if (donor != null) {
          _fullNameController.text = donor.fullName;
          _mobileController.text = donor.mobile ?? '';
          _emailController.text = donor.email ?? '';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.donorId != null;
    final colors = context.authColors;

    return AppScaffold(
      title: isEditing ? 'Edit Donor' : 'Add Donor',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Full Name',
                hint: 'e.g. Raj Sharma',
                controller: _fullNameController,
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: AppSpacing.space16),
              AppTextField(
                label: 'Mobile Number',
                hint: 'e.g. 9876543210 (10 digits)',
                controller: _mobileController,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSpacing.space16),
              AppTextField(
                label: 'Email Address (Optional)',
                hint: 'donor@example.com',
                controller: _emailController,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              // ── Optional Initial Donation Section ───────────────────────
              if (!isEditing) ...[
                const SizedBox(height: AppSpacing.space24),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.space16),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.volunteer_activism_outlined, color: colors.brandOrange, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Add Initial Donation',
                                  style: TextStyle(
                                    color: colors.text,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  'Record a donation & issue receipt along with this donor profile',
                                  style: TextStyle(color: colors.secondaryText, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _addDonationNow,
                            activeThumbColor: colors.brandOrange,
                            onChanged: (val) => setState(() => _addDonationNow = val),
                          ),
                        ],
                      ),
                      if (_addDonationNow) ...[
                        const Divider(height: 24),
                        AppTextField(
                          label: 'Donation Amount (₹)',
                          hint: 'e.g. 5000',
                          controller: _amountController,
                          prefixIcon: Icons.currency_rupee_outlined,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: AppSpacing.space16),
                        Text(
                          'Payment Method',
                          style: TextStyle(
                            color: colors.secondaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: ['Cash', 'UPI', 'Net Banking', 'Cheque'].map((method) {
                            final selected = method == _selectedPaymentMethod;
                            return ChoiceChip(
                              label: Text(method),
                              selected: selected,
                              selectedColor: colors.brandOrange,
                              labelStyle: TextStyle(
                                color: selected ? Colors.white : colors.text,
                                fontWeight: FontWeight.w800,
                              ),
                              onSelected: (_) => setState(() => _selectedPaymentMethod = method),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppSpacing.space16),
                        AppTextField(
                          label: 'Purpose / Category',
                          hint: 'e.g. Ganpati Utsav 2026',
                          controller: _purposeController,
                          prefixIcon: Icons.category_outlined,
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              if (_errorText != null) ...[
                const SizedBox(height: AppSpacing.space16),
                Text(
                  _errorText!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold),
                ),
              ],

              const SizedBox(height: AppSpacing.space32),

              AppButton(
                label: isEditing
                    ? 'Save Donor Profile'
                    : (_addDonationNow ? 'Continue to Payment' : 'Save Donor Only'),
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    setState(() => _errorText = null);
    final fullName = _fullNameController.text.trim();
    final mobile = _mobileController.text.trim();
    final email = _emailController.text.trim();

    if (fullName.isEmpty) {
      setState(() => _errorText = 'Please enter a full name for the donor.');
      return;
    }

    if (mobile.isNotEmpty) {
      final digitsOnly = mobile.replaceAll(RegExp(r'\D'), '');
      if (digitsOnly.length != 10) {
        setState(() => _errorText = 'Mobile number must contain exactly 10 digits.');
        return;
      }
    } else if (email.isEmpty) {
      setState(() => _errorText = 'Please enter a mobile number (10 digits) or email address.');
      return;
    }

    if (email.isNotEmpty && !_isValidEmail(email)) {
      setState(() => _errorText = 'Please enter a valid email address.');
      return;
    }

    final repository = ref.read(donorRepositoryProvider);

    if (widget.donorId != null) {
      // Editing existing donor profile
      setState(() => _isSubmitting = true);
      await repository.updateDonor(
        id: widget.donorId!,
        fullName: fullName,
        mobile: mobile.isEmpty ? null : mobile,
        email: email.isEmpty ? null : email,
      );
      ref.invalidate(donorListProvider);
      ref.invalidate(donorDetailProvider(widget.donorId!));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donor profile updated successfully')),
      );
      Navigator.pop(context);
      return;
    }

    // Creating new donor profile
    if (!_addDonationNow) {
      // Case A: Add donor only (No payment, no receipt)
      setState(() => _isSubmitting = true);
      await repository.createDonor(
        fullName: fullName,
        mobile: mobile.isEmpty ? null : mobile,
        email: email.isEmpty ? null : email,
        status: DonorProfileStatus.active,
      );
      ref.invalidate(donorListProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donor saved successfully (No initial donation)')),
      );
      Navigator.pop(context);
      return;
    }

    // Case B: Add donor + initial donation
    final amountText = _amountController.text.trim();
    final amountVal = double.tryParse(amountText) ?? 0.0;
    if (amountVal <= 0) {
      setState(() => _errorText = 'Please enter a valid donation amount greater than ₹0.');
      return;
    }

    // Check duplicate donor
    final existingDonors = await repository.getDonors();
    final cleanMobile = mobile.replaceAll(RegExp(r'\D'), '');
    Donor? match;
    for (final d in existingDonors) {
      final cleanDMobile = d.mobile?.replaceAll(RegExp(r'\D'), '') ?? '';
      final mobileMatches = cleanMobile.isNotEmpty && cleanDMobile.isNotEmpty && cleanDMobile.endsWith(cleanMobile);
      final nameMatches = d.fullName.toLowerCase() == fullName.toLowerCase();
      if (mobileMatches || nameMatches) {
        match = d;
        break;
      }
    }

    final foundMatch = match;
    if (foundMatch != null && mounted) {
      final shouldProceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Donor Profile Found'),
          content: Text(
            'A donor profile already exists for "${foundMatch.fullName}" (${foundMatch.mobile ?? 'No mobile'}).\n\nWould you like to record this initial donation under the existing donor account?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Record under Existing Donor'),
            ),
          ],
        ),
      );

      if (shouldProceed != true) return;
    }

    if (!mounted) return;

    final colors = context.authColors;
    final amountPaise = (amountVal * 100).round();

    // Show Temporary Confirmation Modal
    showDialog(
      context: context,
      builder: (confirmCtx) {
        return AlertDialog(
          backgroundColor: colors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.verified_user_outlined, color: colors.brandOrange, size: 24),
              const SizedBox(width: 8),
              Text(
                'Confirm Donation',
                style: TextStyle(color: colors.text, fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Review details before issuing official receipt:',
                style: TextStyle(color: colors.secondaryText, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Donor: $fullName', style: TextStyle(color: colors.text, fontWeight: FontWeight.bold)),
                    if (mobile.isNotEmpty) Text('Mobile: $mobile', style: TextStyle(color: colors.secondaryText, fontSize: 12)),
                    Text('Amount: ₹${amountVal.toStringAsFixed(0)}', style: TextStyle(color: colors.brandOrange, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Payment Method: $_selectedPaymentMethod', style: TextStyle(color: colors.secondaryText, fontSize: 12)),
                    Text('Purpose: ${_purposeController.text.trim()}', style: TextStyle(color: colors.secondaryText, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: const Text(
                  '⚡ Direct confirmation mode (No Razorpay gateway required)',
                  style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(confirmCtx),
              child: Text('Cancel', style: TextStyle(color: colors.secondaryText)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.brandOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Navigator.pop(confirmCtx);

                // Collect donation and generate receipt
                final receipt = await ref.read(paymentsProvider.notifier).collectDonationAndGenerateReceipt(
                  donorName: fullName,
                  contact: mobile.isEmpty ? null : mobile,
                  amount: amountVal,
                  paymentMethod: _selectedPaymentMethod,
                );

                // Record donation stats on donor repository
                await repository.recordDonationForDonor(
                  fullName: fullName,
                  mobile: mobile.isEmpty ? null : mobile,
                  amountPaise: amountPaise,
                );

                // Update dashboards & streams
                ref.read(mandalDashboardProvider.notifier).addDonation(
                  amountPaise: amountPaise,
                  paymentMethod: _selectedPaymentMethod,
                  donorName: fullName,
                );
                ref.read(mandalDashboardProvider.notifier).refresh();
                ref.invalidate(donorListProvider);
                ref.invalidate(receiptsProvider);

                if (!context.mounted) return;

                final receiptNo = receipt?.receiptNumber ?? 'RCPT-2026-000001';
                final receiptId = receipt?.id ?? '';

                // Show Receipt Success Dialog
                showDialog(
                  context: context,
                  builder: (successCtx) {
                    return AlertDialog(
                      backgroundColor: colors.card,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      title: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
                          const SizedBox(width: 8),
                          Text(
                            'Donation Successful!',
                            style: TextStyle(color: colors.text, fontSize: 18, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Official digital receipt generated successfully.',
                            style: TextStyle(color: colors.secondaryText, fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colors.surfaceMuted,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: colors.border),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'RECEIPT NO',
                                  style: TextStyle(color: colors.secondaryText, fontSize: 11, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  receiptNo,
                                  style: TextStyle(color: colors.brandOrange, fontSize: 18, fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  fullName,
                                  style: TextStyle(color: colors.text, fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                if (mobile.isNotEmpty)
                                  Text(
                                    'Mobile: $mobile',
                                    style: TextStyle(color: colors.secondaryText, fontSize: 12),
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${amountVal.toStringAsFixed(0)}',
                                  style: TextStyle(color: colors.text, fontSize: 24, fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Method: $_selectedPaymentMethod • Status: Confirmed',
                                  style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(successCtx);
                            if (context.mounted) Navigator.pop(context);
                          },
                          child: Text('Done', style: TextStyle(color: colors.secondaryText)),
                        ),
                        if (receiptId.isNotEmpty)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.brandOrange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              Navigator.pop(successCtx);
                              if (context.mounted) {
                                Navigator.pop(context);
                                context.push('/receipts/$receiptId');
                              }
                            },
                            icon: const Icon(Icons.receipt, size: 16),
                            label: const Text('View Receipt'),
                          ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Printing.layoutPdf(
                              onLayout: (format) async {
                                final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
                                return PdfReceiptGenerator.generateReceiptPdf(
                                  receiptNumber: receiptNo,
                                  mandalName: 'Shree Siddhivinayak Ganpati Mandal',
                                  donorName: fullName,
                                  amountText: currency.format(amountVal),
                                  dateText: DateFormat('d MMM yyyy').format(DateTime.now()),
                                  typeLabel: 'Festival Donation — ${_purposeController.text.trim()}',
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.download, size: 16),
                          label: const Text('PDF'),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Confirm & Issue Receipt'),
            ),
          ],
        );
      },
    );
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }
}
