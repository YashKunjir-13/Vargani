import 'package:flutter/foundation.dart';

enum AssignmentScopeType {
  event,
  area,
  route,
  society,
  village,
  ward,
  contributorPortfolio,
  receiptBook,
  campaign,
}

extension AssignmentScopeTypeExtension on AssignmentScopeType {
  String get label {
    return switch (this) {
      AssignmentScopeType.event => 'Event',
      AssignmentScopeType.area => 'Area',
      AssignmentScopeType.route => 'Route',
      AssignmentScopeType.society => 'Society',
      AssignmentScopeType.village => 'Village',
      AssignmentScopeType.ward => 'Ward',
      AssignmentScopeType.contributorPortfolio => 'Contributor Portfolio',
      AssignmentScopeType.receiptBook => 'Receipt Book',
      AssignmentScopeType.campaign => 'Collection Campaign',
    };
  }
}

enum VolunteerAssignmentStatus {
  planned,
  active,
  completed,
  cancelled,
}

extension VolunteerAssignmentStatusExtension on VolunteerAssignmentStatus {
  String get label {
    return switch (this) {
      VolunteerAssignmentStatus.planned => 'Planned',
      VolunteerAssignmentStatus.active => 'Active',
      VolunteerAssignmentStatus.completed => 'Completed',
      VolunteerAssignmentStatus.cancelled => 'Cancelled',
    };
  }
}

@immutable
class VolunteerAssignment {
  const VolunteerAssignment({
    required this.id,
    required this.volunteerId,
    required this.roleCode,
    required this.scopeType,
    this.scopeReferenceId,
    required this.scopeLabel,
    required this.startsAt,
    this.endsAt,
    required this.status,
    this.assignedByUserId,
    this.endedByUserId,
    this.endReason,
  });

  final String id;
  final String volunteerId;
  final String roleCode;
  final AssignmentScopeType scopeType;
  final String? scopeReferenceId;
  final String scopeLabel;
  final DateTime startsAt;
  final DateTime? endsAt;
  final VolunteerAssignmentStatus status;
  final String? assignedByUserId;
  final String? endedByUserId;
  final String? endReason;
}
