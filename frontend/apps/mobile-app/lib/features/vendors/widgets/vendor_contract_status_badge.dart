import 'package:flutter/material.dart';

import '../../../shared/shared.dart';
import '../models/vendor.dart';

class VendorContractStatusBadge extends StatelessWidget {
  const VendorContractStatusBadge({super.key, required this.status});

  final VendorContractStatus status;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      VendorContractStatus.active => 'Active',
      VendorContractStatus.complete => 'Complete',
      VendorContractStatus.pending => 'Pending',
    };

    final appStatus = switch (status) {
      VendorContractStatus.active => AppStatus.success,
      VendorContractStatus.complete => AppStatus.info,
      VendorContractStatus.pending => AppStatus.pending,
    };

    return AppStatusBadge(label: label, status: appStatus);
  }
}
