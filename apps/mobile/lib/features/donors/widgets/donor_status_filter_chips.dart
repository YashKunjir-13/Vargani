import 'package:flutter/material.dart';

import '../../authentication/presentation/widgets/auth_design_tokens.dart';
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
    final colors = context.authColors;
    final filters = <DonorProfileStatus?>[
      null,
      DonorProfileStatus.active,
      DonorProfileStatus.unclaimed,
      DonorProfileStatus.deactivated,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedStatus == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () => onChanged(filter),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? colors.brandOrange : colors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? colors.brandOrange : colors.border,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colors.brandOrange.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  _labelFor(filter),
                  style: TextStyle(
                    color: isSelected ? Colors.white : colors.text,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
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
