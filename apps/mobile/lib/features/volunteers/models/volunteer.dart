import 'package:flutter/foundation.dart';

enum VolunteerStatus { draft, active, suspended, inactive }

enum VolunteerType {
  general,
  donationCollector,
  eventCoordinator,
  financeVolunteer,
  decoration,
  foodDistribution,
  crowdManagement,
  custom,
}

extension VolunteerTypeLabel on VolunteerType {
  String get label {
    return switch (this) {
      VolunteerType.general => 'General',
      VolunteerType.donationCollector => 'Donation Collector',
      VolunteerType.eventCoordinator => 'Event Coordinator',
      VolunteerType.financeVolunteer => 'Finance Volunteer',
      VolunteerType.decoration => 'Decoration',
      VolunteerType.foodDistribution => 'Food Distribution',
      VolunteerType.crowdManagement => 'Crowd Management',
      VolunteerType.custom => 'Custom',
    };
  }
}

@immutable
class Volunteer {
  const Volunteer({
    required this.id,
    required this.volunteerCode,
    required this.type,
    this.customTypeLabel,
    required this.status,
    required this.fullName,
    required this.mobile,
    this.email,
    this.joinedOn,
    required this.preferredLanguage,
    required this.activeAssignmentCount,
    this.currentAssignmentSummary,
  });

  final String id;
  final String volunteerCode;
  final VolunteerType type;
  final String? customTypeLabel;
  final VolunteerStatus status;
  final String fullName;
  final String mobile;
  final String? email;
  final DateTime? joinedOn;
  final String preferredLanguage;
  final int activeAssignmentCount;
  final String? currentAssignmentSummary;

  Volunteer copyWith({
    String? id,
    String? volunteerCode,
    VolunteerType? type,
    String? customTypeLabel,
    VolunteerStatus? status,
    String? fullName,
    String? mobile,
    String? email,
    DateTime? joinedOn,
    String? preferredLanguage,
    int? activeAssignmentCount,
    String? currentAssignmentSummary,
  }) {
    return Volunteer(
      id: id ?? this.id,
      volunteerCode: volunteerCode ?? this.volunteerCode,
      type: type ?? this.type,
      customTypeLabel: customTypeLabel ?? this.customTypeLabel,
      status: status ?? this.status,
      fullName: fullName ?? this.fullName,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      joinedOn: joinedOn ?? this.joinedOn,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      activeAssignmentCount: activeAssignmentCount ?? this.activeAssignmentCount,
      currentAssignmentSummary: currentAssignmentSummary ?? this.currentAssignmentSummary,
    );
  }
}
