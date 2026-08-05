import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../shared/shared.dart';
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
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
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
    final repository = ref.read(donorRepositoryProvider);

    return AppScaffold(
      title: isEditing ? 'Edit Donor' : 'Add Donor',
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                label: 'Full Name',
                hint: 'Enter donor name',
                controller: _fullNameController,
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: AppSpacing.space16),
              AppTextField(
                label: 'Mobile',
                hint: '9876543210',
                controller: _mobileController,
                prefixIcon: Icons.phone_outlined,
              ),
              const SizedBox(height: AppSpacing.space16),
              AppTextField(
                label: 'Email',
                hint: 'donor@example.com',
                controller: _emailController,
                prefixIcon: Icons.email_outlined,
              ),
              if (_errorText != null) ...[
                const SizedBox(height: AppSpacing.space16),
                Text(
                  _errorText!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const Spacer(),
              AppButton(
                label: 'Save Donor',
                isLoading: _isSubmitting,
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        setState(() => _errorText = null);
                        final fullName = _fullNameController.text.trim();
                        final mobile = _mobileController.text.trim();
                        final email = _emailController.text.trim();

                        if (fullName.isEmpty ||
                            (mobile.isEmpty && email.isEmpty)) {
                          setState(() => _errorText =
                              'Please enter a full name and at least one of mobile or email.');
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
                          await repository.updateDonor(
                            id: widget.donorId!,
                            fullName: fullName,
                            mobile: mobile.isEmpty ? null : mobile,
                            email: email.isEmpty ? null : email,
                          );
                        } else {
                          await repository.createDonor(
                            fullName: fullName,
                            mobile: mobile.isEmpty ? null : mobile,
                            email: email.isEmpty ? null : email,
                          );
                        }
                        if (!mounted) return;
                        setState(() => _isSubmitting = false);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                                isEditing ? 'Donor updated' : 'Donor created'),
                          ),
                        );
                        if (!mounted) return;
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
