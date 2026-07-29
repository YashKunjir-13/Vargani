import 'package:flutter/material.dart';

import '../../../shared/shared.dart';
import '../../../shared/widgets/formatters.dart';
import '../models/donor.dart';

class DonorListItem extends StatelessWidget {
  const DonorListItem({super.key, required this.donor, required this.onTap});

  final Donor donor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = donor.mobile ?? donor.email ?? '';
    return AppListItemCard(
      title: donor.fullName,
      subtitle: subtitle,
      amount: formatPaiseAsRupees(donor.totalConfirmedAmountPaise),
      onTap: onTap,
      status: donor.status == DonorProfileStatus.active
          ? AppStatus.success
          : donor.status == DonorProfileStatus.unclaimed
              ? AppStatus.info
              : donor.status == DonorProfileStatus.deactivated
                  ? AppStatus.neutral
                  : AppStatus.neutral,
    );
  }
}
