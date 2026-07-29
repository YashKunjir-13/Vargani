import 'dart:async';

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
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.vendorId != null;
    final repository = ref.read(vendorRepositoryProvider);

    return AppScaffold(
      title: isEditing ? 'Edit Vendor' : 'Add Vendor',
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              AppTextField(
                label: 'Name',
                hint: 'Enter vendor name',
                controller: _nameController,
                prefixIcon: Icons.business_outlined,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Category',
                hint: 'Decoration / DJ / Security',
                controller: _categoryController,
                prefixIcon: Icons.category_outlined,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Contact Person',
                hint: 'Enter contact person',
                controller: _contactPersonController,
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Mobile',
                hint: '9876543210',
                controller: _mobileController,
                prefixIcon: Icons.phone_outlined,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Email',
                hint: 'vendor@example.com',
                controller: _emailController,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Address',
                hint: 'Enter address',
                controller: _addressController,
                prefixIcon: Icons.location_on_outlined,
              ),
              if (_errorText != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(_errorText!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: AppSpacing.lg),
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

                        if (name.isEmpty) {
                          setState(
                              () => _errorText = 'Vendor name is required.');
                          return;
                        }
                        if (mobile.isNotEmpty &&
                            RegExp(r'^\d+$').hasMatch(mobile) == false) {
                          setState(() => _errorText =
                              'Mobile number must contain digits only.');
                          return;
                        }
                        if (email.isNotEmpty && !_isValidEmail(email)) {
                          setState(() => _errorText =
                              'Please enter a valid email address.');
                          return;
                        }

                        setState(() => _isSubmitting = true);
                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);
                        await Future<void>.delayed(
                            const Duration(milliseconds: 500));
                        if (!mounted) return;
                        if (isEditing) {
                          await repository.updateVendor(
                            id: widget.vendorId!,
                            name: name,
                            contactPerson:
                                contactPerson.isEmpty ? null : contactPerson,
                            mobile: mobile.isEmpty ? null : mobile,
                            email: email.isEmpty ? null : email,
                            address: address.isEmpty ? null : address,
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
                            category: category.isEmpty ? null : category,
                          );
                        }
                        if (!mounted) return;
                        setState(() => _isSubmitting = false);
                        messenger.showSnackBar(SnackBar(
                            content: Text(isEditing
                                ? 'Vendor updated'
                                : 'Vendor created')));
                        navigator.pop();
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }
}
