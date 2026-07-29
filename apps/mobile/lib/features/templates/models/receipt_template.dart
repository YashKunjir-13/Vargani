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
}

class ReceiptTemplate {
  final String id;
  final String name;
  final String mandalName;
  final String imageUrl;
  final bool isActive;
  final List<FieldMarker> markers;

  const ReceiptTemplate({
    required this.id,
    required this.name,
    required this.mandalName,
    required this.imageUrl,
    required this.isActive,
    required this.markers,
  });

  ReceiptTemplate copyWith({
    String? name,
    bool? isActive,
    List<FieldMarker>? markers,
  }) {
    return ReceiptTemplate(
      id: id,
      name: name ?? this.name,
      mandalName: mandalName,
      imageUrl: imageUrl,
      isActive: isActive ?? this.isActive,
      markers: markers ?? this.markers,
    );
  }
}
