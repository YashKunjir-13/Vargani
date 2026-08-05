import 'package:flutter/material.dart';

import '../../../shared/shared.dart';
import '../models/advertisement.dart';

class AdvertisementStatusBadge extends StatelessWidget {
  const AdvertisementStatusBadge({super.key, required this.status});

  final AdvertisementStatus status;

  @override
  Widget build(BuildContext context) {
    final appStatus = switch (status) {
      AdvertisementStatus.active => AppStatus.success,
      AdvertisementStatus.booked => AppStatus.info,
      AdvertisementStatus.pending => AppStatus.warning,
    };

    return AppStatusBadge(
      label: status.label,
      status: appStatus,
    );
  }
}
