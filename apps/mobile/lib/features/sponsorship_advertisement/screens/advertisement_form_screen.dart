import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../shared/shared.dart';
import '../models/advertisement.dart';
import '../providers/advertisement_providers.dart';

class AdvertisementFormScreen extends ConsumerStatefulWidget {
  const AdvertisementFormScreen({super.key, this.advertisementId});

  final String? advertisementId;

  @override
  ConsumerState<AdvertisementFormScreen> createState() =>
      _AdvertisementFormScreenState();
}

class _AdvertisementFormScreenState
    extends ConsumerState<AdvertisementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _advertiserNameController = TextEditingController();
  final _placementDetailController = TextEditingController();
  final _amountController = TextEditingController();

  AdvertisementType _selectedType = AdvertisementType.banner;
  bool _isLoading = false;
  Advertisement? _existingAd;

  @override
  void initState() {
    super.initState();
    if (widget.advertisementId != null) {
      _loadExisting();
    }
  }

  Future<void> _loadExisting() async {
    final repository = ref.read(advertisementRepositoryProvider);
    final ad = await repository.getAdvertisementById(widget.advertisementId!);
    if (ad != null && mounted) {
      setState(() {
        _existingAd = ad;
        _advertiserNameController.text = ad.advertiserName;
        _placementDetailController.text = ad.placementDetail ?? '';
        _selectedType = ad.type;
        // Internal money is in paise, convert to rupees integer for input UI
        _amountController.text = (ad.amountPaise ~/ 100).toString();
      });
    }
  }

  @override
  void dispose() {
    _advertiserNameController.dispose();
    _placementDetailController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.advertisementId != null;

    return AppScaffold(
      title: isEditing ? 'Edit Advertisement' : 'Book Advertisement',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _advertiserNameController,
                label: 'Advertiser Name',
                hint: 'e.g. Sai Supermarket',
                prefixIcon: Icons.storefront_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Advertiser Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<AdvertisementType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Advertisement Type',
                  prefixIcon: Icon(Icons.campaign_outlined),
                ),
                items: AdvertisementType.values.map((type) {
                  return DropdownMenuItem<AdvertisementType>(
                    value: type,
                    child: Text(type.label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _placementDetailController,
                label: 'Placement Detail',
                hint: "e.g. Banner • 4'x8' • Main Gate",
                prefixIcon: Icons.place_outlined,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _amountController,
                label: 'Amount (₹)',
                hint: 'e.g. 15000',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.currency_rupee_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Amount is required';
                  }
                  final parsed = int.tryParse(value.trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Please enter a valid positive integer amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: isEditing ? 'Save Changes' : 'Book Advertisement',
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

    final rupees = int.parse(_amountController.text.trim());
    final paise = rupees * 100;

    final advertisement = Advertisement(
      id: widget.advertisementId ?? 'ad-${DateTime.now().millisecondsSinceEpoch}',
      advertiserName: _advertiserNameController.text.trim(),
      type: _selectedType,
      placementDetail: _placementDetailController.text.trim().isEmpty
          ? null
          : _placementDetailController.text.trim(),
      status: _existingAd?.status ?? AdvertisementStatus.pending,
      amountPaise: paise,
      createdAt: _existingAd?.createdAt ?? DateTime.now(),
    );

    final repository = ref.read(advertisementRepositoryProvider);
    await repository.saveAdvertisement(advertisement);

    ref.invalidate(advertisementListProvider);
    if (widget.advertisementId != null) {
      ref.invalidate(advertisementDetailProvider(widget.advertisementId!));
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
