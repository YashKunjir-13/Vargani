import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/session/session_controller.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_image_picker.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/pauti_app_bar.dart';
import '../models/contribution.dart';
import '../state/contributions_notifier.dart';

class CreateContributionScreen extends ConsumerStatefulWidget {
  const CreateContributionScreen({super.key});

  @override
  ConsumerState<CreateContributionScreen> createState() => _CreateContributionScreenState();
}

class _CreateContributionScreenState extends ConsumerState<CreateContributionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contributorController = TextEditingController();
  final _contactController = TextEditingController();
  final _itemDescriptionController = TextEditingController();
  final _weightController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _estimatedValueController = TextEditingController();
  final _notesController = TextEditingController();

  DonationType _donationType = DonationType.food;
  String? _certificatePhotoPath;

  @override
  void dispose() {
    _contributorController.dispose();
    _contactController.dispose();
    _itemDescriptionController.dispose();
    _weightController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _estimatedValueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final sessionUser = ref.read(sessionControllerProvider).user;
    final currentUserId = sessionUser?.id ?? sessionUser?.displayName ?? 'user-volunteer-1';

    ref.read(contributionsProvider.notifier).record(
          contributorName: _contributorController.text.trim(),
          contact: _contactController.text.trim().isEmpty ? null : _contactController.text.trim(),
          donationType: _donationType,
          itemDescription: _itemDescriptionController.text.trim().isEmpty ? null : _itemDescriptionController.text.trim(),
          weightGrams: double.tryParse(_weightController.text),
          quantity: double.tryParse(_quantityController.text),
          unit: _unitController.text.trim().isEmpty ? null : _unitController.text.trim(),
          estimatedValue: double.tryParse(_estimatedValueController.text),
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          certificatePhotoUrl: _certificatePhotoPath,
          recordedBy: currentUserId,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Recorded ${_donationType.label} contribution -- receipt issued'),
        backgroundColor: Colors.green,
      ),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGoldOrSilver = _donationType.isPreciousMetal;

    return Scaffold(
      appBar: PautiAppBar(
        title: L10n.tr(ref, 'contributions'),
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
              // Contributor Details
              AppTextField(
                label: 'Contributor Name *',
                controller: _contributorController,
                prefixIcon: Icons.person_outline,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Contributor name is required' : null,
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: L10n.tr(ref, 'contact'),
                isOptional: true,
                controller: _contactController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
              ),
              const SizedBox(height: 16),

              // Donation Type Picker
              Text(
                L10n.tr(ref, 'donation_type'),
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<DonationType>(
                initialValue: _donationType,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: DonationType.values
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text('${type.label} ${type.isPreciousMetal ? "✨ (Special)" : ""}'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _donationType = value);
                  }
                },
              ),
              const SizedBox(height: 20),

              // Dynamic Gold / Silver Section (Revealed ONLY when relevant)
              if (isGoldOrSilver) ...[
                AppCard(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.diamond_outlined, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              L10n.tr(ref, 'gold_silver_fields'),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Detailed weight calibration, estimated valuation, and purity certificate attachment.',
                        style: theme.textTheme.bodySmall,
                      ),
                      const Divider(height: 20),

                      AppTextField(
                        label: L10n.tr(ref, 'item_description'),
                        isOptional: true,
                        controller: _itemDescriptionController,
                        prefixIcon: Icons.description_outlined,
                        hintText: 'e.g. 24K Gold Coin, Silver Crown, Gold Necklace',
                      ),
                      const SizedBox(height: 14),

                      AppTextField(
                        label: L10n.tr(ref, 'weight_grams'),
                        isOptional: true,
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        prefixIcon: Icons.scale_outlined,
                        hintText: 'e.g. 10.5',
                      ),
                      const SizedBox(height: 14),

                      AppTextField(
                        label: L10n.tr(ref, 'estimated_value'),
                        isOptional: true,
                        controller: _estimatedValueController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        prefixIcon: Icons.currency_rupee,
                        hintText: 'e.g. 75000',
                      ),
                      const SizedBox(height: 14),

                      AppImagePicker(
                        label: L10n.tr(ref, 'certificate_photo'),
                        imagePath: _certificatePhotoPath,
                        hintText: 'Tap to attach Gold/Silver Purity Certificate',
                        icon: Icons.verified_outlined,
                        onPickImage: () {
                          setState(() {
                            _certificatePhotoPath = 'gold_purity_cert_2026.jpg';
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Attached gold purity certificate photo')),
                          );
                        },
                        onRemoveImage: () => setState(() => _certificatePhotoPath = null),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ] else ...[
                AppTextField(
                  label: 'Item Description / Details *',
                  controller: _itemDescriptionController,
                  prefixIcon: Icons.inventory_2_outlined,
                  hintText: 'e.g. 50kg Rice, Dhol Pathak + DJ, Flower Decor',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Item description is required' : null,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: AppTextField(
                        label: 'Quantity',
                        isOptional: true,
                        controller: _quantityController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        prefixIcon: Icons.numbers_outlined,
                        hintText: 'e.g. 50',
                        validator: (v) {
                          if (v != null && v.trim().isNotEmpty) {
                            final val = double.tryParse(v);
                            if (val == null || val < 0) return 'Enter valid quantity';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: AppTextField(
                        label: 'Unit',
                        isOptional: true,
                        controller: _unitController,
                        prefixIcon: Icons.straighten_outlined,
                        hintText: 'e.g. kg, pcs, set',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Estimated Value (₹)',
                  isOptional: true,
                  controller: _estimatedValueController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: Icons.currency_rupee,
                  hintText: 'e.g. 3500',
                  validator: (v) {
                    if (v != null && v.trim().isNotEmpty) {
                      final val = double.tryParse(v);
                      if (val == null || val < 0) return 'Enter valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Additional Notes',
                  isOptional: true,
                  controller: _notesController,
                  prefixIcon: Icons.notes_outlined,
                  hintText: 'e.g. Delivered to Mandal kitchen',
                ),
                const SizedBox(height: 20),
              ],

              AppButton(
                label: 'Record Non-Monetary Contribution',
                icon: Icons.volunteer_activism_outlined,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
