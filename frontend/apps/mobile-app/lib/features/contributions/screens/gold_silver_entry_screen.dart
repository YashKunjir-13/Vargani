import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/pauti_app_bar.dart';

class GoldSilverEntryScreen extends ConsumerStatefulWidget {
  const GoldSilverEntryScreen({super.key});

  @override
  ConsumerState<GoldSilverEntryScreen> createState() =>
      _GoldSilverEntryScreenState();
}

class _GoldSilverEntryScreenState extends ConsumerState<GoldSilverEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _donorNameController = TextEditingController(text: 'Sunita Deshmukh');
  final _phoneController = TextEditingController(text: '9822019283');
  final _itemDescriptionController =
      TextEditingController(text: 'Gold Mukut / Crown for Lord Ganesha');
  final _weightController = TextEditingController(text: '12.5');
  final _estimatedValueController = TextEditingController(text: '95000');
  final _certNumberController = TextEditingController(text: 'CERT-BIS-99420');

  String _metalType = 'Gold';
  String _purity = '22K (916)';
  bool _hasCertPhoto = true;

  @override
  void dispose() {
    _donorNameController.dispose();
    _phoneController.dispose();
    _itemDescriptionController.dispose();
    _weightController.dispose();
    _estimatedValueController.dispose();
    _certNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PautiAppBar(
        title: 'Gold & Silver In-Kind Entry',
        subtitle: 'Precious Metal Contribution & Cert Photo',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              AppCard(
                color: Colors.amber.shade50,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.amber.shade200,
                      child: Icon(Icons.workspace_premium,
                          color: Colors.amber.shade900, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Precious Metal Vault Log',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.amber.shade900),
                          ),
                          Text(
                            'Generates specialized CRCPT- receipt with weight & purity cert',
                            style: TextStyle(
                                fontSize: 12, color: Colors.amber.shade800),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              Text('DONOR DETAILS', style: AppTypography.caption(context)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _donorNameController,
                decoration: const InputDecoration(
                    labelText: 'Donor Full Name',
                    prefixIcon: Icon(Icons.person)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                    labelText: 'Mobile Number', prefixIcon: Icon(Icons.phone)),
              ),

              const SizedBox(height: AppSpacing.lg),

              Text('PRECIOUS METAL SPECIFICATION',
                  style: AppTypography.caption(context)),
              const SizedBox(height: 8),

              // Metal Type Selector
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Gold (सुवर्ण)')),
                      selected: _metalType == 'Gold',
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _metalType = 'Gold';
                            _purity = '22K (916)';
                          });
                        }
                      },
                      selectedColor: Colors.amber.shade300,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Silver (चांदी)')),
                      selected: _metalType == 'Silver',
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _metalType = 'Silver';
                            _purity = '92.5 Sterling';
                          });
                        }
                      },
                      selectedColor: Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _itemDescriptionController,
                decoration: const InputDecoration(
                    labelText: 'Item Description (Ornaments / Crown / Idol)',
                    prefixIcon: Icon(Icons.shopping_bag_outlined)),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Weight (Grams)', suffixText: 'g'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _purity,
                      decoration:
                          const InputDecoration(labelText: 'Purity / Hallmark'),
                      items: (_metalType == 'Gold'
                              ? ['24K (999)', '22K (916)', '18K (750)']
                              : ['99.9 Pure', '92.5 Sterling'])
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _purity = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _estimatedValueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Estimated Market Value (₹)',
                    prefixIcon: Icon(Icons.attach_money)),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _certNumberController,
                decoration: const InputDecoration(
                    labelText: 'Valuation / BIS Hallmark Cert #',
                    prefixIcon: Icon(Icons.verified)),
              ),
              const SizedBox(height: 16),

              // Cert Photo Uploader Mock
              GestureDetector(
                onTap: () {
                  setState(() => _hasCertPhoto = !_hasCertPhoto);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.grey.shade300, style: BorderStyle.solid),
                  ),
                  child: Row(
                    children: [
                      Icon(
                          _hasCertPhoto
                              ? Icons.check_circle
                              : Icons.camera_alt_outlined,
                          color: _hasCertPhoto ? Colors.green : Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _hasCertPhoto
                                  ? 'Purity Certificate Attached'
                                  : 'Attach Valuation Photo',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _hasCertPhoto
                                  ? 'hallmark_cert_sunita.jpg (240 KB)'
                                  : 'Tap to capture / upload certificate photo',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Logged $_metalType Offer (${_weightController.text}g) - Receipt CRCPT-2025-092 Generated!'),
                      backgroundColor: Colors.amber.shade900,
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('Save & Issue In-Kind Receipt'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.amber.shade900,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
