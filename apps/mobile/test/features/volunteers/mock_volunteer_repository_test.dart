import 'package:flutter_test/flutter_test.dart';
import 'package:pauti_pustak_mobile/features/volunteers/data/mock_volunteer_repository.dart';
import 'package:pauti_pustak_mobile/features/volunteers/models/volunteer.dart';

void main() {
  late MockVolunteerRepository repository;

  setUp(() {
    repository = MockVolunteerRepository();
  });

  test('filters volunteers by search, status, and type', () async {
    final volunteers = await repository.getVolunteers(
      search: 'san',
      status: VolunteerStatus.active,
      type: VolunteerType.donationCollector,
    );

    expect(volunteers, isNotEmpty);
    expect(
        volunteers
            .every((volunteer) => volunteer.status == VolunteerStatus.active),
        isTrue);
    expect(
        volunteers.every(
            (volunteer) => volunteer.type == VolunteerType.donationCollector),
        isTrue);
  });

  test('creates and updates volunteers in memory', () async {
    final created = await repository.createVolunteer(
      fullName: 'New Volunteer',
      type: VolunteerType.general,
      mobile: '9876543210',
      email: 'volunteer@example.com',
    );

    expect(created.fullName, 'New Volunteer');
    expect(created.status, VolunteerStatus.draft);

    final updated = await repository.updateVolunteer(
      id: created.id,
      status: VolunteerStatus.active,
      fullName: 'Updated Volunteer',
    );

    expect(updated, isNotNull);
    expect(updated!.status, VolunteerStatus.active);
    expect(updated.fullName, 'Updated Volunteer');
  });
}
