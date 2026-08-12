import 'package:uuid/uuid.dart';

import '../models/volunteer.dart';
import '../models/volunteer_assignment.dart';
import 'volunteer_repository.dart';

class MockVolunteerRepository implements VolunteerRepository {
  MockVolunteerRepository() {
    _volunteers = _seedVolunteers();
  }

  late List<Volunteer> _volunteers;
  final Map<String, List<VolunteerAssignment>> _assignments = {};

  @override
  Future<List<Volunteer>> getVolunteers({
    String search = '',
    VolunteerStatus? status,
    VolunteerType? type,
  }) async {
    final query = search.trim().toLowerCase();
    return _volunteers.where((volunteer) {
      final matchesStatus = status == null || volunteer.status == status;
      final matchesType = type == null || volunteer.type == type;
      final haystack = '${volunteer.fullName} ${volunteer.volunteerCode}'.toLowerCase();
      final matchesQuery = query.isEmpty || haystack.contains(query);
      return matchesStatus && matchesType && matchesQuery;
    }).toList();
  }

  @override
  Future<Volunteer?> getVolunteerById(String id) async {
    return _volunteers.where((volunteer) => volunteer.id == id).firstOrNull;
  }

  @override
  Future<Volunteer> createVolunteer({
    required String fullName,
    required VolunteerType type,
    String? customTypeLabel,
    required String mobile,
    String? email,
    String? address,
    String? emergencyContact,
    String preferredLanguage = 'mr',
    DateTime? joinedOn,
  }) async {
    final volunteer = Volunteer(
      id: const Uuid().v4(),
      volunteerCode: _nextVolunteerCode(),
      type: type,
      customTypeLabel: type == VolunteerType.custom ? customTypeLabel : null,
      status: VolunteerStatus.draft,
      fullName: fullName,
      mobile: mobile,
      email: email,
      address: address,
      emergencyContact: emergencyContact,
      joinedOn: joinedOn ?? DateTime.now(),
      preferredLanguage: preferredLanguage,
      activeAssignmentCount: 0,
      currentAssignmentSummary: null,
    );
    _volunteers.add(volunteer);
    _assignments[volunteer.id] = [];
    return volunteer;
  }

  @override
  Future<Volunteer?> updateVolunteer({
    required String id,
    String? fullName,
    VolunteerType? type,
    String? customTypeLabel,
    String? mobile,
    String? email,
    String? address,
    String? emergencyContact,
    String? preferredLanguage,
    DateTime? joinedOn,
    VolunteerStatus? status,
  }) async {
    final index = _volunteers.indexWhere((v) => v.id == id);
    if (index == -1) return null;
    final existing = _volunteers[index];
    final updated = existing.copyWith(
      fullName: fullName,
      type: type,
      customTypeLabel: customTypeLabel,
      mobile: mobile,
      email: email,
      address: address,
      emergencyContact: emergencyContact,
      preferredLanguage: preferredLanguage,
      joinedOn: joinedOn,
      status: status,
      version: existing.version + 1,
    );
    _volunteers[index] = updated;
    return updated;
  }

  @override
  Future<Volunteer?> activateVolunteer({
    required String id,
    String? auditReason,
  }) async {
    return updateVolunteer(
      id: id,
      status: VolunteerStatus.active,
    );
  }

  @override
  Future<Volunteer?> suspendVolunteer({
    required String id,
    required String reason,
  }) async {
    return updateVolunteer(
      id: id,
      status: VolunteerStatus.suspended,
    );
  }

  @override
  Future<Volunteer?> deactivateVolunteer({
    required String id,
    required String reason,
  }) async {
    return updateVolunteer(
      id: id,
      status: VolunteerStatus.inactive,
    );
  }

  @override
  Future<Volunteer?> linkUserIdentity({
    required String id,
    required String userId,
  }) async {
    final index = _volunteers.indexWhere((v) => v.id == id);
    if (index == -1) return null;
    final updated = _volunteers[index].copyWith(linkedUserId: userId);
    _volunteers[index] = updated;
    return updated;
  }

  @override
  Future<Volunteer?> unlinkUserIdentity({
    required String id,
  }) async {
    final index = _volunteers.indexWhere((v) => v.id == id);
    if (index == -1) return null;
    final updated = _volunteers[index].copyWith(linkedUserId: null);
    _volunteers[index] = updated;
    return updated;
  }

  @override
  Future<List<VolunteerAssignment>> getAssignmentsForVolunteer(String volunteerId) async {
    return [...(_assignments[volunteerId] ?? [])];
  }

  @override
  Future<VolunteerAssignment> addAssignment({
    required String volunteerId,
    required String roleCode,
    required AssignmentScopeType scopeType,
    String? scopeReferenceId,
    required String scopeLabel,
    required DateTime startsAt,
    DateTime? endsAt,
    VolunteerAssignmentStatus status = VolunteerAssignmentStatus.active,
  }) async {
    final assignment = VolunteerAssignment(
      id: const Uuid().v4(),
      volunteerId: volunteerId,
      roleCode: roleCode,
      scopeType: scopeType,
      scopeReferenceId: scopeReferenceId,
      scopeLabel: scopeLabel,
      startsAt: startsAt,
      endsAt: endsAt,
      status: status,
    );
    _assignments.putIfAbsent(volunteerId, () => []).add(assignment);

    // Update active assignment summary on volunteer
    final index = _volunteers.indexWhere((v) => v.id == volunteerId);
    if (index != -1) {
      final existing = _volunteers[index];
      final newCount = existing.activeAssignmentCount + (status == VolunteerAssignmentStatus.active ? 1 : 0);
      _volunteers[index] = existing.copyWith(
        activeAssignmentCount: newCount,
        currentAssignmentSummary: '$roleCode — ${scopeType.label}: $scopeLabel',
      );
    }
    return assignment;
  }

  List<Volunteer> _seedVolunteers() {
    return [];
  }

  String _nextVolunteerCode() {
    final next = _volunteers.length + 1;
    return 'VOL-${next.toString().padLeft(4, '0')}';
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
