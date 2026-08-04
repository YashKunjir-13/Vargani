import 'package:flutter/material.dart';

class FieldMarker {
  final String id;
  final String label;
  Offset position; // Normalized position (0.0 to 1.0)
  Size size; // Normalized size (0.0 to 1.0)
  final Color color;

  FieldMarker({
    required this.id,
    required this.label,
    required this.position,
    required this.size,
    required this.color,
  });

  FieldMarker copyWith({
    Offset? position,
    Size? size,
  }) {
    return FieldMarker(
      id: id,
      label: label,
      position: position ?? this.position,
      size: size ?? this.size,
      color: color,
    );
  }

  factory FieldMarker.fromJson(Map<String, dynamic> json) {
    final key = json['fieldKey'] as String? ?? 'field';
    final x = (json['x'] is num) ? (json['x'] as num).toDouble() : 0.1;
    final y = (json['y'] is num) ? (json['y'] as num).toDouble() : 0.1;

    String label = key;
    Color color = Colors.blue;

    switch (key) {
      case 'donor_name':
        label = 'Donor Name';
        color = Colors.blue;
        break;
      case 'amount':
        label = 'Amount (₹)';
        color = Colors.green;
        break;
      case 'receipt_no':
        label = 'Receipt No';
        color = Colors.orange;
        break;
      case 'date':
        label = 'Date & Time';
        color = Colors.purple;
        break;
      case 'signature':
        label = 'Trustee Signature';
        color = Colors.teal;
        break;
      default:
        label = key;
        color = Colors.indigo;
    }

    return FieldMarker(
      id: key,
      label: label,
      position: Offset(x, y),
      size: const Size(0.3, 0.08),
      color: color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fieldKey': id,
      'page': 1,
      'x': position.dx,
      'y': position.dy,
      'fontSize': 12,
    };
  }
}

class ReceiptTemplate {
  final String id;
  final String name;
  final String mandalName;
  final String imageUrl;
  final bool isActive;
  final String detectionStatus;
  final List<FieldMarker> markers;

  const ReceiptTemplate({
    required this.id,
    required this.name,
    required this.mandalName,
    required this.imageUrl,
    required this.isActive,
    required this.detectionStatus,
    required this.markers,
  });

  ReceiptTemplate copyWith({
    String? name,
    bool? isActive,
    String? detectionStatus,
    List<FieldMarker>? markers,
  }) {
    return ReceiptTemplate(
      id: id,
      name: name ?? this.name,
      mandalName: mandalName,
      imageUrl: imageUrl,
      isActive: isActive ?? this.isActive,
      detectionStatus: detectionStatus ?? this.detectionStatus,
      markers: markers ?? this.markers,
    );
  }

  factory ReceiptTemplate.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final version = json['version'] ?? 1;
    final type = json['templateType'] as String? ?? 'RECEIPT';
    final name = 'Template v$version ($type)';
    final sourceUrl = json['sourceFileUrl'] as String? ?? '';
    final isActive = json['isActive'] as bool? ?? false;
    final detectionStatus = json['detectionStatus'] as String? ?? 'AUTO_DETECTED';

    final fieldMapList = json['fieldMap'] as List<dynamic>? ?? [];
    List<FieldMarker> markers = fieldMapList
        .map((item) => FieldMarker.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    if (markers.isEmpty) {
      markers = [
        FieldMarker(id: 'donor_name', label: 'Donor Name', position: const Offset(0.20, 0.32), size: const Size(0.55, 0.08), color: Colors.blue),
        FieldMarker(id: 'amount', label: 'Amount (₹)', position: const Offset(0.70, 0.45), size: const Size(0.25, 0.08), color: Colors.green),
        FieldMarker(id: 'receipt_no', label: 'Receipt No', position: const Offset(0.70, 0.20), size: const Size(0.25, 0.06), color: Colors.orange),
        FieldMarker(id: 'date', label: 'Date & Time', position: const Offset(0.10, 0.20), size: const Size(0.30, 0.06), color: Colors.purple),
        FieldMarker(id: 'signature', label: 'Trustee Signature', position: const Offset(0.65, 0.75), size: const Size(0.30, 0.12), color: Colors.teal),
      ];
    }

    return ReceiptTemplate(
      id: id,
      name: name,
      mandalName: 'Mandal Financial Trust',
      imageUrl: sourceUrl.startsWith('http') ? sourceUrl : 'assets/images/template_saffron.png',
      isActive: isActive,
      detectionStatus: detectionStatus,
      markers: markers,
    );
  }
}
