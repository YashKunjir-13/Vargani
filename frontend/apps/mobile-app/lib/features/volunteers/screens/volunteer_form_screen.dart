import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../shared/shared.dart';
import '../models/volunteer.dart';
import '../providers/volunteer_providers.dart';

class VolunteerFormScreen extends ConsumerStatefulWidget {
  const VolunteerFormScreen({super.key, this.volunteerId});

  final String? volunteerId;

  @override
  ConsumerState<VolunteerFormScreen> createState() =>
      _VolunteerFormScreenState();
}

class _VolunteerFormScreenState extends ConsumerState<VolunteerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _customTypeController = TextEditingController();
  VolunteerType? _type = VolunteerType.general;
  VolunteerStatus? _status = VolunteerStatus.draft;
  DateTime? _joinedOn;
  String _preferredLanguage = 'mr';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final volunteerAsync =
        ref.read(volunteerDetailProvider(widget.volunteerId ?? ''));
    volunteerAsync.whenData((volunteer) {
      if (volunteer != null) {
        _fullNameController.text = volunteer.fullName;
        _mobileController.text = volunteer.mobile;
        _emailController.text = volunteer.email ?? '';
        _addressController.text = volunteer.address ?? '';
        _emergencyContactController.text = volunteer.emergencyContact ?? '';
        _customTypeController.text = volunteer.customTypeLabel ?? '';
        _type = volunteer.type;
        _status = volunteer.status;
        _joinedOn = volunteer.joinedOn;
        _preferredLanguage = volunteer.preferredLanguage;
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _customTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeControllerProvider);
    final role = ref.watch(roleProvider);
    final canManageVolunteers = role == UserRole.trustPresident ||
        role == UserRole.vicePresident ||
        role == UserRole.treasurer;

    if (!canManageVolunteers) {
      return const AppScaffold(
        title: 'Volunteer Form',
        body:
            AppEmptyState(title: 'You do not have access to manage volunteers'),
      );
    }

    return AppScaffold(
      title: widget.volunteerId == null ? 'New Volunteer' : 'Edit Volunteer',
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.space24),
          children: [
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(labelText: 'Full name'),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.space16),
            TextFormField(
              controller: _mobileController,
              decoration: const InputDecoration(labelText: 'Mobile number'),
              keyboardType: TextInputType.phone,
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.space16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email (optional)'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppSpacing.space16),
            TextFormField(
              controller: _emergencyContactController,
              decoration: const InputDecoration(
                  labelText: 'Emergency contact (optional)'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSpacing.space16),
            TextFormField(
              controller: _addressController,
              decoration:
                  const InputDecoration(labelText: 'Address (optional)'),
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.space16),
            DropdownButtonFormField<VolunteerType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Volunteer type'),
              items: [
                for (final type in VolunteerType.values)
                  DropdownMenuItem(value: type, child: Text(type.label)),
              ],
              onChanged: (value) => setState(() => _type = value),
            ),
            const SizedBox(height: AppSpacing.space16),
            if (_type == VolunteerType.custom)
              TextFormField(
                controller: _customTypeController,
                decoration:
                    const InputDecoration(labelText: 'Custom type label'),
              ),
            if (_type == VolunteerType.custom)
              const SizedBox(height: AppSpacing.space16),
            DropdownButtonFormField<String>(
              initialValue: _preferredLanguage,
              decoration:
                  const InputDecoration(labelText: 'Preferred language'),
              items: const [
                DropdownMenuItem(value: 'mr', child: Text('Marathi (मराठी)')),
                DropdownMenuItem(value: 'hi', child: Text('Hindi (हिंदी)')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (value) =>
                  setState(() => _preferredLanguage = value ?? 'mr'),
            ),
            const SizedBox(height: AppSpacing.space16),
            DropdownButtonFormField<VolunteerStatus>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: [
                for (final status in VolunteerStatus.values)
                  DropdownMenuItem(value: status, child: Text(status.label)),
              ],
              onChanged: (value) => setState(() => _status = value),
            ),
            const SizedBox(height: AppSpacing.space16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Joined on'),
              subtitle: Text(_joinedOn == null
                  ? 'Select date'
                  : _joinedOn!.toLocal().toString().split(' ').first),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _joinedOn ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                );
                if (picked != null) setState(() => _joinedOn = picked);
              },
            ),
            const SizedBox(height: AppSpacing.space24),
            AppButton(
              label: _isLoading ? 'Saving...' : 'Save Volunteer',
              onPressed: _isLoading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);
    final repository = ref.read(volunteerRepositoryProvider);
    if (widget.volunteerId == null) {
      await repository.createVolunteer(
        fullName: _fullNameController.text.trim(),
        type: _type ?? VolunteerType.general,
        customTypeLabel: _customTypeController.text.trim().isEmpty
            ? null
            : _customTypeController.text.trim(),
        mobile: _mobileController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        emergencyContact: _emergencyContactController.text.trim().isEmpty
            ? null
            : _emergencyContactController.text.trim(),
        preferredLanguage: _preferredLanguage,
        joinedOn: _joinedOn,
      );
    } else {
      await repository.updateVolunteer(
        id: widget.volunteerId!,
        fullName: _fullNameController.text.trim(),
        type: _type,
        customTypeLabel: _customTypeController.text.trim().isEmpty
            ? null
            : _customTypeController.text.trim(),
        mobile: _mobileController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        emergencyContact: _emergencyContactController.text.trim().isEmpty
            ? null
            : _emergencyContactController.text.trim(),
        preferredLanguage: _preferredLanguage,
        joinedOn: _joinedOn,
        status: _status,
      );
    }
    if (!mounted) return;
    ref.invalidate(volunteerListProvider);
    ref.invalidate(volunteerDetailProvider(widget.volunteerId ?? ''));
    Navigator.pop(context);
    setState(() => _isLoading = false);
  }
}
