import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../models/volunteer.dart';

class VolunteerTypeBadge extends StatelessWidget {
  const VolunteerTypeBadge(
      {super.key, required this.type, this.customTypeLabel});

  final VolunteerType type;
  final String? customTypeLabel;

  @override
  Widget build(BuildContext context) {
    final label = type == VolunteerType.custom &&
            customTypeLabel != null &&
            customTypeLabel!.isNotEmpty
        ? customTypeLabel!
        : type.label;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16, vertical: AppSpacing.space4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}
