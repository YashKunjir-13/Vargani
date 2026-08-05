import 'package:flutter/material.dart';

import '../../../shared/shared.dart';
import '../models/sponsorship.dart';

class SponsorshipStatusBadge extends StatelessWidget {
  const SponsorshipStatusBadge({super.key, required this.status});

  final SponsorshipStatus status;

  @override
  Widget build(BuildContext context) {
    final appStatus = switch (status) {
      SponsorshipStatus.confirmed => AppStatus.success,
      SponsorshipStatus.pledged => AppStatus.info,
      SponsorshipStatus.pending => AppStatus.warning,
    };

    return AppStatusBadge(
      label: status.label,
      status: appStatus,
    );
  }
}
