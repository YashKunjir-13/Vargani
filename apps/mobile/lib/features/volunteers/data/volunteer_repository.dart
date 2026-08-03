import '../models/volunteer.dart';
import '../models/volunteer_assignment.dart';

abstract class VolunteerRepository {
  Future<List<Volunteer>> getVolunteers({
    String search = '',
    VolunteerStatus? status,
    VolunteerType? type,
  });

  Future<Volunteer?> getVolunteerById(String id);

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
  });

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
  });

  Future<Volunteer?> activateVolunteer({
    required String id,
    String? auditReason,
  });

  Future<Volunteer?> suspendVolunteer({
    required String id,
    required String reason,
  });

  Future<Volunteer?> deactivateVolunteer({
    required String id,
    required String reason,
  });

  Future<Volunteer?> linkUserIdentity({
    required String id,
    required String userId,
  });

  Future<Volunteer?> unlinkUserIdentity({
    required String id,
  });

  Future<List<VolunteerAssignment>> getAssignmentsForVolunteer(String volunteerId);

  Future<VolunteerAssignment> addAssignment({
    required String volunteerId,
    required String roleCode,
    required AssignmentScopeType scopeType,
    String? scopeReferenceId,
    required String scopeLabel,
    required DateTime startsAt,
    DateTime? endsAt,
    VolunteerAssignmentStatus status = VolunteerAssignmentStatus.active,
  });
}
