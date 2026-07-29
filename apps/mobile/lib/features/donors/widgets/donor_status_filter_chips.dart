import 'package:flutter/material.dart';

import '../models/donor.dart';

class DonorStatusFilterChips extends StatelessWidget {
  const DonorStatusFilterChips({
    super.key,
    required this.selectedStatus,
    required this.onChanged,
  });

  final DonorProfileStatus? selectedStatus;
  final ValueChanged<DonorProfileStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    final filters = <DonorProfileStatus?>[null, DonorProfileStatus.active, DonorProfileStatus.unclaimed, DonorProfileStatus.deactivated];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final filter in filters)
          ChoiceChip(
            label: Text(_labelFor(filter)),
            selected: selectedStatus == filter,
            onSelected: (_) => onChanged(filter),
          ),
      ],
    );
  }

  String _labelFor(DonorProfileStatus? status) {
    return switch (status) {
      null => 'All',
      DonorProfileStatus.active => 'Active',
      DonorProfileStatus.unclaimed => 'Unclaimed',
      DonorProfileStatus.deactivated => 'Deactivated',
      DonorProfileStatus.merged => 'Merged',
    };
  }
}
