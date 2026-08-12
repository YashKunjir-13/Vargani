import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../shared/shared.dart';
import '../providers/vendor_providers.dart';

class VendorFormScreen extends ConsumerStatefulWidget {
  const VendorFormScreen({super.key, this.vendorId});

  final String? vendorId;

  @override
  ConsumerState<VendorFormScreen> createState() => _VendorFormScreenState();
}

class _VendorFormScreenState extends ConsumerState<VendorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _gstinController = TextEditingController();
  final _panController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _bankIfscController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _contactPersonController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _gstinController.dispose();
    _panController.dispose();
    _bankAccountController.dispose();
    _bankIfscController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.vendorId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final vendor = ref.read(vendorDetailProvider(widget.vendorId!)).value;
        if (vendor != null) {
          _nameController.text = vendor.name;
          _categoryController.text = vendor.category ?? '';
          _contactPersonController.text = vendor.contactPerson ?? '';
          _mobileController.text = vendor.mobile ?? '';
          _emailController.text = vendor.email ?? '';
          _addressController.text = vendor.address ?? '';
          _gstinController.text = vendor.gstin ?? '';
          _panController.text = vendor.pan ?? '';
          _bankAccountController.text = vendor.bankAccount ?? '';
          _bankIfscController.text = vendor.bankIfsc ?? '';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeControllerProvider);
    final isEditing = widget.vendorId != null;
    final repository = ref.read(vendorRepositoryProvider);

    return AppScaffold(
      title: isEditing ? 'Edit Vendor' : 'Add Vendor',
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              AppTextField(
                label: 'Vendor Name *',
                hint: 'Enter vendor name',
                controller: _nameController,
                prefixIcon: Icons.business_outlined,
              ),
              const SizedBox(height: AppSpacing.space16),
              AppTextField(
                label: 'Category (Optional)',
                hint: 'Decoration / DJ / Catering / Sound',
                controller: _categoryController,
                prefixIcon: Icons.category_outlined,
              ),
              const SizedBox(height: AppSpacing.space16),
              AppTextField(
                label: 'Contact Person (Optional)',
                hint: 'Enter contact person name',
                controller: _contactPersonController,
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: AppSpacing.space16),
              AppTextField(
                label: 'Mobile Number (Optional)',
                hint: '9876543210',
                controller: _mobileController,
                prefixIcon: Icons.phone_outlined,
              ),
              const SizedBox(height: AppSpacing.space16),
              AppTextField(
                label: 'Email (Optional)',
                hint: 'vendor@example.com',
                controller: _emailController,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: AppSpacing.space16),
              AppTextField(
                label: 'Address (Optional)',
                hint: 'Enter full business address',
                controller: _addressController,
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: AppSpacing.space24),
              Text(
                'Tax & Banking Information (Optional)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSpacing.space12),
              AppTextField(
                label: 'GSTIN (Tax ID) (Optional)',
                hint: '27AAAAA0000A1Z5',
                controller: _gstinController,
                prefixIcon: Icons.receipt_long_outlined,
              ),
              const SizedBox(height: AppSpacing.space16),
              AppTextField(
                label: 'PAN Tax ID (Optional)',
                hint: 'ABCDE1234F',
                controller: _panController,
                prefixIcon: Icons.badge_outlined,
              ),
              const SizedBox(height: AppSpacing.space16),
              AppTextField(
                label: 'Bank Account Number (Optional)',
                hint: 'Account Number for Payouts',
                controller: _bankAccountController,
                prefixIcon: Icons.account_balance_outlined,
              ),
              const SizedBox(height: AppSpacing.space16),
              AppTextField(
                label: 'Bank IFSC Code (Optional)',
                hint: 'SBIN0001234',
                controller: _bankIfscController,
                prefixIcon: Icons.code_outlined,
              ),
              if (_errorText != null) ...[
                const SizedBox(height: AppSpacing.space16),
                Text(
                  _errorText!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: AppSpacing.space24),
              AppButton(
                label: 'Save Vendor',
                isLoading: _isSubmitting,
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        setState(() => _errorText = null);
                        final name = _nameController.text.trim();
                        final category = _categoryController.text.trim();
                        final contactPerson =
                            _contactPersonController.text.trim();
                        final mobile = _mobileController.text.trim();
                        final email = _emailController.text.trim();
                        final address = _addressController.text.trim();
                        final gstin = _gstinController.text.trim();
                        final pan = _panController.text.trim();
                        final bankAccount = _bankAccountController.text.trim();
                        final bankIfsc = _bankIfscController.text.trim();

                        if (name.isEmpty) {
                          setState(
                              () => _errorText = 'Vendor name is required.');
                          return;
                        }
                        if (mobile.isNotEmpty &&
                            !RegExp(r'^\d+$').hasMatch(mobile)) {
                          setState(() => _errorText =
                              'Mobile number must contain digits only.');
                          return;
                        }

                        setState(() => _isSubmitting = true);
                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);

                        if (isEditing) {
                          await repository.updateVendor(
                            id: widget.vendorId!,
                            name: name,
                            contactPerson:
                                contactPerson.isEmpty ? null : contactPerson,
                            mobile: mobile.isEmpty ? null : mobile,
                            email: email.isEmpty ? null : email,
                            address: address.isEmpty ? null : address,
                            gstin: gstin.isEmpty ? null : gstin,
                            pan: pan.isEmpty ? null : pan,
                            bankAccount:
                                bankAccount.isEmpty ? null : bankAccount,
                            bankIfsc: bankIfsc.isEmpty ? null : bankIfsc,
                            category: category.isEmpty ? null : category,
                          );
                        } else {
                          await repository.createVendor(
                            name: name,
                            contactPerson:
                                contactPerson.isEmpty ? null : contactPerson,
                            mobile: mobile.isEmpty ? null : mobile,
                            email: email.isEmpty ? null : email,
                            address: address.isEmpty ? null : address,
                            gstin: gstin.isEmpty ? null : gstin,
                            pan: pan.isEmpty ? null : pan,
                            bankAccount:
                                bankAccount.isEmpty ? null : bankAccount,
                            bankIfsc: bankIfsc.isEmpty ? null : bankIfsc,
                            category: category.isEmpty ? null : category,
                          );
                        }

                        if (!mounted) return;
                        ref.invalidate(vendorListProvider);
                        if (widget.vendorId != null) {
                          ref.invalidate(
                              vendorDetailProvider(widget.vendorId!));
                        }
                        setState(() => _isSubmitting = false);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              isEditing ? 'Vendor updated' : 'Vendor created',
                            ),
                          ),
                        );
                        navigator.pop();
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
