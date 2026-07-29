import 'package:flutter/material.dart';

import '../../../shared/shared.dart';
import '../models/volunteer.dart';

class VolunteerStatusBadge extends StatelessWidget {
  const VolunteerStatusBadge({super.key, required this.status});

  final VolunteerStatus status;

  @override
  Widget build(BuildContext context) {
    final appStatus = switch (status) {
      VolunteerStatus.active => AppStatus.success,
      VolunteerStatus.draft => AppStatus.info,
      VolunteerStatus.suspended => AppStatus.warning,
      VolunteerStatus.inactive => AppStatus.neutral,
    };

    final label = switch (status) {
      VolunteerStatus.active => 'Active',
      VolunteerStatus.draft => 'Draft',
      VolunteerStatus.suspended => 'Suspended',
      VolunteerStatus.inactive => 'Inactive',
    };

    return AppStatusBadge(label: label, status: appStatus);
  }
}
