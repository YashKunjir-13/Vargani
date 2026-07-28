import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/receipt_template.dart';

final initialTemplates = [
  ReceiptTemplate(
    id: 'tmpl-001',
    name: 'Traditional Saffron & Gold Header Template',
    mandalName: 'Shree Ganesh Mandal',
    imageUrl: 'assets/images/template_saffron.png',
    isActive: true,
    markers: [
      FieldMarker(
        id: 'donor_name',
        label: 'Donor Name',
        position: const Offset(0.20, 0.32),
        size: const Size(0.55, 0.08),
        color: Colors.blue,
      ),
      FieldMarker(
        id: 'amount',
        label: 'Amount (₹)',
        position: const Offset(0.70, 0.45),
        size: const Size(0.25, 0.08),
        color: Colors.green,
      ),
      FieldMarker(
        id: 'receipt_no',
        label: 'Receipt No',
        position: const Offset(0.70, 0.20),
        size: const Size(0.25, 0.06),
        color: Colors.orange,
      ),
      FieldMarker(
        id: 'date',
        label: 'Date & Time',
        position: const Offset(0.10, 0.20),
        size: const Size(0.30, 0.06),
        color: Colors.purple,
      ),
      FieldMarker(
        id: 'signature',
        label: 'Trustee Signature',
        position: const Offset(0.65, 0.75),
        size: const Size(0.30, 0.12),
        color: Colors.teal,
      ),
    ],
  ),
  ReceiptTemplate(
    id: 'tmpl-002',
    name: 'Modern Royal Blue Digital Receipt Template',
    mandalName: 'Shree Ganesh Mandal',
    imageUrl: 'assets/images/template_navy.png',
    isActive: false,
    markers: [
      FieldMarker(
        id: 'donor_name',
        label: 'Donor Name',
        position: const Offset(0.15, 0.35),
        size: const Size(0.60, 0.08),
        color: Colors.blue,
      ),
      FieldMarker(
        id: 'amount',
        label: 'Amount (₹)',
        position: const Offset(0.65, 0.48),
        size: const Size(0.28, 0.08),
        color: Colors.green,
      ),
      FieldMarker(
        id: 'receipt_no',
        label: 'Receipt No',
        position: const Offset(0.65, 0.18),
        size: const Size(0.28, 0.06),
        color: Colors.orange,
      ),
      FieldMarker(
        id: 'date',
        label: 'Date & Time',
        position: const Offset(0.15, 0.18),
        size: const Size(0.35, 0.06),
        color: Colors.purple,
      ),
      FieldMarker(
        id: 'signature',
        label: 'Trustee Signature',
        position: const Offset(0.60, 0.78),
        size: const Size(0.32, 0.12),
        color: Colors.teal,
      ),
    ],
  ),
];

class TemplatesNotifier extends Notifier<List<ReceiptTemplate>> {
  @override
  List<ReceiptTemplate> build() => initialTemplates;

  void updateMarkerPosition(String templateId, String markerId, Offset newNormalizedPosition) {
    state = [
      for (final tmpl in state)
        if (tmpl.id == templateId)
          tmpl.copyWith(
            markers: [
              for (final m in tmpl.markers)
                if (m.id == markerId) m.copyWith(position: newNormalizedPosition) else m
            ],
          )
        else
          tmpl
    ];
  }

  void activateTemplate(String templateId) {
    state = [
      for (final tmpl in state) tmpl.copyWith(isActive: tmpl.id == templateId)
    ];
  }

  void addTemplate(ReceiptTemplate newTmpl) {
    state = [...state, newTmpl];
  }
}

final templatesProvider = NotifierProvider<TemplatesNotifier, List<ReceiptTemplate>>(TemplatesNotifier.new);

final activeTemplateProvider = Provider<ReceiptTemplate>((ref) {
  final templates = ref.watch(templatesProvider);
  return templates.firstWhere((t) => t.isActive, orElse: () => templates.first);
});
