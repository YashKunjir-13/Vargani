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
  Future<List<Volunteer>> getVolunteers({String search = '', VolunteerStatus? status, VolunteerType? type}) async {
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
      joinedOn: joinedOn,
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
    String? preferredLanguage,
    DateTime? joinedOn,
    VolunteerStatus? status,
  }) async {
    final index = _volunteers.indexWhere((volunteer) => volunteer.id == id);
    if (index == -1) {
      return null;
    }
    final existing = _volunteers[index];
    final updated = existing.copyWith(
      fullName: fullName,
      type: type,
      customTypeLabel: customTypeLabel,
      mobile: mobile,
      email: email,
      preferredLanguage: preferredLanguage,
      joinedOn: joinedOn,
      status: status,
    );
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
    required String scopeType,
    required String scopeLabel,
    required DateTime startsAt,
    DateTime? endsAt,
    String assignmentStatus = 'active',
  }) async {
    final assignment = VolunteerAssignment(
      id: const Uuid().v4(),
      volunteerId: volunteerId,
      roleCode: roleCode,
      scopeType: scopeType,
      scopeLabel: scopeLabel,
      startsAt: startsAt,
      endsAt: endsAt,
      assignmentStatus: assignmentStatus,
    );
    _assignments.putIfAbsent(volunteerId, () => []).add(assignment);
    return assignment;
  }

  List<Volunteer> _seedVolunteers() {
    final volunteers = [
      Volunteer(
        id: 'volunteer-1',
        volunteerCode: 'VOL-0001',
        type: VolunteerType.donationCollector,
        status: VolunteerStatus.active,
        fullName: 'Sanjay Patil',
        mobile: '9876543210',
        email: 'sanjay@example.com',
        joinedOn: DateTime(2024, 4, 10),
        preferredLanguage: 'mr',
        activeAssignmentCount: 1,
        currentAssignmentSummary: 'Collector — Area 3, Ward B',
      ),
      Volunteer(
        id: 'volunteer-2',
        volunteerCode: 'VOL-0002',
        type: VolunteerType.eventCoordinator,
        status: VolunteerStatus.draft,
        fullName: 'Meera Deshmukh',
        mobile: '9098765432',
        email: 'meera@example.com',
        joinedOn: DateTime(2024, 5, 22),
        preferredLanguage: 'en',
        activeAssignmentCount: 0,
        currentAssignmentSummary: null,
      ),
      Volunteer(
        id: 'volunteer-3',
        volunteerCode: 'VOL-0003',
        type: VolunteerType.financeVolunteer,
        status: VolunteerStatus.active,
        fullName: 'Anil Shinde',
        mobile: '9988776655',
        email: 'anil@example.com',
        joinedOn: DateTime(2024, 6, 14),
        preferredLanguage: 'hi',
        activeAssignmentCount: 2,
        currentAssignmentSummary: 'Finance Desk — Receipt Book 2',
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
        currentAssignmentSummary: 'Decor — Main Hall',
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
        currentAssignmentSummary: 'Kitchen Team — Ward C',
      ),
      Volunteer(
        id: 'volunteer-6',
        volunteerCode: 'VOL-0006',
        type: VolunteerType.crowdManagement,
        status: VolunteerStatus.inactive,
        fullName: 'Nisha Pawar',
        mobile: '8887654321',
        email: 'nisha@example.com',
        joinedOn: DateTime(2024, 9, 19),
        preferredLanguage: 'en',
        activeAssignmentCount: 0,
        currentAssignmentSummary: null,
      ),
      Volunteer(
        id: 'volunteer-7',
        volunteerCode: 'VOL-0007',
        type: VolunteerType.general,
        status: VolunteerStatus.active,
        fullName: 'Vikram More',
        mobile: '9011223344',
        email: 'vikram@example.com',
        joinedOn: DateTime(2024, 10, 7),
        preferredLanguage: 'hi',
        activeAssignmentCount: 1,
        currentAssignmentSummary: 'General Support — Gate 2',
      ),
      Volunteer(
        id: 'volunteer-8',
        volunteerCode: 'VOL-0008',
        type: VolunteerType.custom,
        customTypeLabel: 'Transport Lead',
        status: VolunteerStatus.active,
        fullName: 'Aruna Bhosale',
        mobile: '8889991122',
        email: 'aruna@example.com',
        joinedOn: DateTime(2024, 11, 3),
        preferredLanguage: 'mr',
        activeAssignmentCount: 0,
        currentAssignmentSummary: null,
      ),
      Volunteer(
        id: 'volunteer-9',
        volunteerCode: 'VOL-0009',
        type: VolunteerType.donationCollector,
        status: VolunteerStatus.draft,
        fullName: 'Ravi Gaikwad',
        mobile: '7000112233',
        email: 'ravi@example.com',
        joinedOn: DateTime(2024, 12, 2),
        preferredLanguage: 'en',
        activeAssignmentCount: 0,
        currentAssignmentSummary: null,
      ),
      Volunteer(
        id: 'volunteer-10',
        volunteerCode: 'VOL-0010',
        type: VolunteerType.eventCoordinator,
        status: VolunteerStatus.active,
        fullName: 'Kavita Kale',
        mobile: '7666554433',
        email: 'kavita@example.com',
        joinedOn: DateTime(2025, 1, 12),
        preferredLanguage: 'hi',
        activeAssignmentCount: 2,
        currentAssignmentSummary: 'Coordinator — Main Stage',
      ),
    ];

    for (final volunteer in volunteers) {
      _assignments[volunteer.id] = [];
      if (volunteer.id == 'volunteer-1') {
        _assignments[volunteer.id] = [
          VolunteerAssignment(
            id: 'assignment-1',
            volunteerId: volunteer.id,
            roleCode: 'Donation Collector',
            scopeType: 'area',
            scopeLabel: 'Area 3, Ward B',
            startsAt: DateTime(2025, 1, 2),
            assignmentStatus: 'active',
          ),
        ];
      }
      if (volunteer.id == 'volunteer-3') {
        _assignments[volunteer.id] = [
          VolunteerAssignment(
            id: 'assignment-2',
            volunteerId: volunteer.id,
            roleCode: 'Finance Volunteer',
            scopeType: 'receiptBook',
            scopeLabel: 'Receipt Book 2',
            startsAt: DateTime(2024, 12, 20),
            assignmentStatus: 'planned',
          ),
        ];
      }
    }

    return volunteers;
  }

  String _nextVolunteerCode() {
    final next = _volunteers.length + 1;
    return 'VOL-${next.toString().padLeft(4, '0')}';
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
