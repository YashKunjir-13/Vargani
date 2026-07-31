import '../models/donor.dart';

abstract class DonorRepository {
  Future<List<Donor>> getDonors({String? search, DonorProfileStatus? status});

  Future<Donor?> getDonorById(String id);

  Future<Donor> createDonor({
    required String fullName,
    String? mobile,
    String? email,
    DonorProfileStatus status = DonorProfileStatus.unclaimed,
  });

  Future<Donor?> updateDonor({
    required String id,
    String? fullName,
    String? mobile,
    String? email,
    DonorProfileStatus? status,
    DateTime? claimedAt,
  });

  Future<Donor?> claimDonor({required String id});

  Future<bool> mergeDonor({
    required String survivingDonorId,
    required String mergedDonorId,
    required String reason,
  });
}
