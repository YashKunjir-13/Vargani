import 'package:flutter/foundation.dart';

@immutable
class VolunteerAssignment {
  const VolunteerAssignment({
    required this.id,
    required this.volunteerId,
    required this.roleCode,
    required this.scopeType,
    required this.scopeLabel,
    required this.startsAt,
    this.endsAt,
    required this.assignmentStatus,
  });

  final String id;
  final String volunteerId;
  final String roleCode;
  final String scopeType;
  final String scopeLabel;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String assignmentStatus;
}
