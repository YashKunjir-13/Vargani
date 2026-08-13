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

    test('records donation for donor and updates total count and amount',
        () async {
      final donor = await repository.recordDonationForDonor(
        fullName: 'Raj Sharma',
        mobile: '9999999999',
        amountPaise: 500000,
      );

      expect(donor.fullName, 'Raj Sharma');
      expect(donor.mobile, '9999999999');
      expect(donor.totalContributionsCount, 1);
      expect(donor.totalConfirmedAmountPaise, 500000);

      final updatedDonor = await repository.recordDonationForDonor(
        fullName: 'Raj Sharma',
        mobile: '9999999999',
        amountPaise: 200000,
      );

      expect(updatedDonor.totalContributionsCount, 2);
      expect(updatedDonor.totalConfirmedAmountPaise, 700000);
    });
  });
}
