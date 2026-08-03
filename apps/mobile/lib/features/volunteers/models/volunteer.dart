import 'package:flutter/foundation.dart';

enum VolunteerStatus { draft, active, suspended, inactive }

extension VolunteerStatusExtension on VolunteerStatus {
  String get label {
    return switch (this) {
      VolunteerStatus.draft => 'Draft',
      VolunteerStatus.active => 'Active',
      VolunteerStatus.suspended => 'Suspended',
      VolunteerStatus.inactive => 'Inactive',
    };
  }
}

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
    this.linkedUserId,
    required this.type,
    this.customTypeLabel,
    required this.status,
    required this.fullName,
    required this.mobile,
    this.email,
    this.address,
    this.emergencyContact,
    this.joinedOn,
    required this.preferredLanguage,
    this.profileDocumentId,
    this.version = 1,
    required this.activeAssignmentCount,
    this.currentAssignmentSummary,
  });

  final String id;
  final String volunteerCode;
  final String? linkedUserId;
  final VolunteerType type;
  final String? customTypeLabel;
  final VolunteerStatus status;
  final String fullName;
  final String mobile;
  final String? email;
  final String? address;
  final String? emergencyContact;
  final DateTime? joinedOn;
  final String preferredLanguage;
  final String? profileDocumentId;
  final int version;
  final int activeAssignmentCount;
  final String? currentAssignmentSummary;

  bool get hasLinkedUser => linkedUserId != null && linkedUserId!.trim().isNotEmpty;

  bool get collectionAuthorityGranted =>
      status == VolunteerStatus.active &&
      (type == VolunteerType.donationCollector || activeAssignmentCount > 0);

  Volunteer copyWith({
    String? id,
    String? volunteerCode,
    String? linkedUserId,
    VolunteerType? type,
    String? customTypeLabel,
    VolunteerStatus? status,
    String? fullName,
    String? mobile,
    String? email,
    String? address,
    String? emergencyContact,
    DateTime? joinedOn,
    String? preferredLanguage,
    String? profileDocumentId,
    int? version,
    int? activeAssignmentCount,
    String? currentAssignmentSummary,
  }) {
    return Volunteer(
      id: id ?? this.id,
      volunteerCode: volunteerCode ?? this.volunteerCode,
      linkedUserId: linkedUserId ?? this.linkedUserId,
      type: type ?? this.type,
      customTypeLabel: customTypeLabel ?? this.customTypeLabel,
      status: status ?? this.status,
      fullName: fullName ?? this.fullName,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      joinedOn: joinedOn ?? this.joinedOn,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      profileDocumentId: profileDocumentId ?? this.profileDocumentId,
      version: version ?? this.version,
      activeAssignmentCount: activeAssignmentCount ?? this.activeAssignmentCount,
      currentAssignmentSummary: currentAssignmentSummary ?? this.currentAssignmentSummary,
    );
  }
}
