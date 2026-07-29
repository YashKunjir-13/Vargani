import 'package:flutter_test/flutter_test.dart';
import 'package:pauti_pustak_mobile/features/donors/data/mock_donor_repository.dart';
import 'package:pauti_pustak_mobile/features/donors/models/donor.dart';

void main() {
  group('MockDonorRepository', () {
    late MockDonorRepository repository;

    setUp(() {
      repository = MockDonorRepository();
    });

    test('filters donors by search and status while hiding merged by default',
        () async {
      final donors = await repository.getDonors(
          search: 'ar', status: DonorProfileStatus.active);

      expect(donors, isNotEmpty);
      expect(donors.every((donor) => donor.status == DonorProfileStatus.active),
          isTrue);
      expect(
          donors.every((donor) =>
              donor.fullName.toLowerCase().contains('ar') ||
              (donor.mobile?.contains('ar') ?? false) ||
              (donor.email?.contains('ar') ?? false)),
          isTrue);
    });

    test('creates and updates a donor in memory', () async {
      final created = await repository.createDonor(
        fullName: 'New Donor',
        mobile: '9876543210',
        email: 'new@example.com',
      );

      expect(created.fullName, 'New Donor');
      expect(created.status, DonorProfileStatus.unclaimed);

      final updated = await repository.updateDonor(
        id: created.id,
        fullName: 'Updated Donor',
        mobile: '9123456780',
      );

      expect(updated, isNotNull);
      expect(updated!.fullName, 'Updated Donor');
      expect(updated.mobile, '9123456780');
    });
  });
}
