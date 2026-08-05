import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../shared/shared.dart';
import '../models/sponsorship.dart';
import '../providers/sponsorship_providers.dart';

class SponsorshipFormScreen extends ConsumerStatefulWidget {
  const SponsorshipFormScreen({super.key, this.sponsorshipId});

  final String? sponsorshipId;

  @override
  ConsumerState<SponsorshipFormScreen> createState() =>
      _SponsorshipFormScreenState();
}

class _SponsorshipFormScreenState extends ConsumerState<SponsorshipFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sponsorNameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _mobileController = TextEditingController();
  final _pledgedAmountController = TextEditingController();

  SponsorshipTier _selectedTier = SponsorshipTier.gold;
  bool _isLoading = false;
  Sponsorship? _existingSponsorship;

  @override
  void initState() {
    super.initState();
    if (widget.sponsorshipId != null) {
      _loadExisting();
    }
  }

  Future<void> _loadExisting() async {
    final repository = ref.read(sponsorshipRepositoryProvider);
    final sponsorship = await repository.getSponsorshipById(widget.sponsorshipId!);
    if (sponsorship != null && mounted) {
      setState(() {
        _existingSponsorship = sponsorship;
        _sponsorNameController.text = sponsorship.sponsorName;
        _contactPersonController.text = sponsorship.contactPerson ?? '';
        _mobileController.text = sponsorship.mobile ?? '';
        _selectedTier = sponsorship.tier;
        _pledgedAmountController.text = (sponsorship.pledgedAmountPaise ~/ 100).toString();
      });
    }
  }

  @override
  void dispose() {
    _sponsorNameController.dispose();
    _contactPersonController.dispose();
    _mobileController.dispose();
    _pledgedAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.sponsorshipId != null;

    return AppScaffold(
      title: isEditing ? 'Edit Sponsor' : 'Add Sponsor',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _sponsorNameController,
                label: 'Sponsor Name',
                hint: 'e.g. Patil Motors Pvt. Ltd.',
                prefixIcon: Icons.business_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Sponsor Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.space16),
              AppTextField(
                controller: _contactPersonController,
                label: 'Contact Person',
                hint: 'e.g. Sanjay Patil',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: AppSpacing.space16),
              AppTextField(
                controller: _mobileController,
                label: 'Mobile',
                hint: 'e.g. 9822012345',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
              ),
              const SizedBox(height: AppSpacing.space16),
              DropdownButtonFormField<SponsorshipTier>(
                initialValue: _selectedTier,
                decoration: const InputDecoration(
                  labelText: 'Sponsorship Tier',
                  prefixIcon: Icon(Icons.workspace_premium_outlined),
                ),
                items: SponsorshipTier.values.map((tier) {
                  return DropdownMenuItem<SponsorshipTier>(
                    value: tier,
                    child: Text(tier.label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedTier = value;
                    });
                  }
                },
              ),
              const SizedBox(height: AppSpacing.space16),
              AppTextField(
                controller: _pledgedAmountController,
                label: 'Pledged Amount (₹)',
                hint: 'e.g. 250000',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.currency_rupee_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Pledged Amount is required';
                  }
                  final parsed = int.tryParse(value.trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Please enter a valid positive integer amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.space32),
              AppButton(
                label: isEditing ? 'Save Changes' : 'Add Sponsor',
                isLoading: _isLoading,
                onPressed: _saveForm,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final rupees = int.parse(_pledgedAmountController.text.trim());
    final paise = rupees * 100;

    final sponsorship = Sponsorship(
      id: widget.sponsorshipId ?? 'spon-${DateTime.now().millisecondsSinceEpoch}',
      sponsorName: _sponsorNameController.text.trim(),
      contactPerson: _contactPersonController.text.trim().isEmpty
          ? null
          : _contactPersonController.text.trim(),
      mobile: _mobileController.text.trim().isEmpty
          ? null
          : _mobileController.text.trim(),
      tier: _selectedTier,
      status: _existingSponsorship?.status ?? SponsorshipStatus.pledged,
      pledgedAmountPaise: paise,
      confirmedAmountPaise: _existingSponsorship?.confirmedAmountPaise ?? 0,
      createdAt: _existingSponsorship?.createdAt ?? DateTime.now(),
    );

    final repository = ref.read(sponsorshipRepositoryProvider);
    await repository.saveSponsorship(sponsorship);

    ref.invalidate(sponsorshipListProvider);
    if (widget.sponsorshipId != null) {
      ref.invalidate(sponsorshipDetailProvider(widget.sponsorshipId!));
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
