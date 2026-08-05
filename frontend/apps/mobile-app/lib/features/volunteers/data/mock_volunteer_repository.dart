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
    final list = [
      Volunteer(
        id: 'volunteer-1',
        volunteerCode: 'VOL-0001',
        linkedUserId: 'user-auth-101',
        type: VolunteerType.donationCollector,
        status: VolunteerStatus.active,
        fullName: 'Sanjay Patil',
        mobile: '9876543210',
        email: 'sanjay@example.com',
        address: 'Flat 302, Sai Residency, Ward B, Mumbai',
        emergencyContact: '9822334455 (Brother)',
        joinedOn: DateTime(2024, 4, 10),
        preferredLanguage: 'mr',
        activeAssignmentCount: 1,
        currentAssignmentSummary: 'Collector — Area: Area 3, Ward B',
      ),
      Volunteer(
        id: 'volunteer-2',
        volunteerCode: 'VOL-0002',
        type: VolunteerType.eventCoordinator,
        status: VolunteerStatus.draft,
        fullName: 'Meera Deshmukh',
        mobile: '9098765432',
        email: 'meera@example.com',
        address: 'B-12 Anand Nagar, Pune',
        emergencyContact: '9000112233',
        joinedOn: DateTime(2024, 5, 22),
        preferredLanguage: 'en',
        activeAssignmentCount: 0,
        currentAssignmentSummary: null,
      ),
      Volunteer(
        id: 'volunteer-3',
        volunteerCode: 'VOL-0003',
        linkedUserId: 'user-auth-103',
        type: VolunteerType.financeVolunteer,
        status: VolunteerStatus.active,
        fullName: 'Anil Shinde',
        mobile: '9988776655',
        email: 'anil@example.com',
        address: 'Line 4, Shivaji Chowk, Thane',
        emergencyContact: '9988001122',
        joinedOn: DateTime(2024, 6, 14),
        preferredLanguage: 'hi',
        activeAssignmentCount: 2,
        currentAssignmentSummary: 'Finance Desk — Receipt Book: Book 2',
      ),
      Volunteer(
        id: 'volunteer-4',
        volunteerCode: 'VOL-0004',
        type: VolunteerType.decoration,
        status: VolunteerStatus.suspended,
        fullName: 'Priya Kulkarni',
        mobile: '9123456780',
        email: 'priya@example.com',
        joinedOn: DateTime(2024, 7, 1),
        preferredLanguage: 'mr',
        activeAssignmentCount: 1,
        currentAssignmentSummary: 'Decor — Event: Main Hall Stage',
      ),
      Volunteer(
        id: 'volunteer-5',
        volunteerCode: 'VOL-0005',
        type: VolunteerType.foodDistribution,
        status: VolunteerStatus.active,
        fullName: 'Rahul Jadhav',
        mobile: '7776543210',
        email: 'rahul@example.com',
        joinedOn: DateTime(2024, 8, 9),
        preferredLanguage: 'mr',
        activeAssignmentCount: 1,
        currentAssignmentSummary: 'Kitchen Team — Ward: Ward C',
      ),
    ];

    for (final volunteer in list) {
      _assignments[volunteer.id] = [];
      if (volunteer.id == 'volunteer-1') {
        _assignments[volunteer.id] = [
          VolunteerAssignment(
            id: 'assignment-1',
            volunteerId: volunteer.id,
            roleCode: 'Donation Collector',
            scopeType: AssignmentScopeType.area,
            scopeLabel: 'Area 3, Ward B',
            startsAt: DateTime(2025, 1, 2),
            status: VolunteerAssignmentStatus.active,
          ),
        ];
      }
      if (volunteer.id == 'volunteer-3') {
        _assignments[volunteer.id] = [
          VolunteerAssignment(
            id: 'assignment-2',
            volunteerId: volunteer.id,
            roleCode: 'Finance Volunteer',
            scopeType: AssignmentScopeType.receiptBook,
            scopeLabel: 'Receipt Book 2',
            startsAt: DateTime(2024, 12, 20),
            status: VolunteerAssignmentStatus.planned,
          ),
        ];
      }
    }

    return list;
  }

  String _nextVolunteerCode() {
    final next = _volunteers.length + 1;
    return 'VOL-${next.toString().padLeft(4, '0')}';
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
