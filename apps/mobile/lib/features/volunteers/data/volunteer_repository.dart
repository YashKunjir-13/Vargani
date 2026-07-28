import '../models/volunteer.dart';
import '../models/volunteer_assignment.dart';

abstract class VolunteerRepository {
  Future<List<Volunteer>> getVolunteers({String search = '', VolunteerStatus? status, VolunteerType? type});
  Future<Volunteer?> getVolunteerById(String id);
  Future<Volunteer> createVolunteer({
    required String fullName,
    required VolunteerType type,
    String? customTypeLabel,
    required String mobile,
    String? email,
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
    String? preferredLanguage,
    DateTime? joinedOn,
    VolunteerStatus? status,
  });
  Future<List<VolunteerAssignment>> getAssignmentsForVolunteer(String volunteerId);
  Future<VolunteerAssignment> addAssignment({
    required String volunteerId,
    required String roleCode,
    required String scopeType,
    required String scopeLabel,
    required DateTime startsAt,
    DateTime? endsAt,
    String assignmentStatus = 'active',
  });
}
