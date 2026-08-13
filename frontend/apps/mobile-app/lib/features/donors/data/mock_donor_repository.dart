import 'package:uuid/uuid.dart';

import '../models/donor.dart';
import 'donor_repository.dart';

class MockDonorRepository implements DonorRepository {
  MockDonorRepository() {
    _seedDonors();
  }

  final List<Donor> _donors = [];
  final _uuid = const Uuid();

  void _seedDonors() {
    final now = DateTime.now();
    final seedData = [
      {
        'fullName': 'Aarav Mehta',
        'mobile': '9876543210',
        'email': 'aarav@example.com',
        'status': DonorProfileStatus.active,
        'claimedAt': now.subtract(const Duration(days: 5)),
        'createdAt': now.subtract(const Duration(days: 21)),
        'count': 12,
        'amount': 1250000
      },
      {
        'fullName': 'Meera Shah',
        'mobile': '9123456780',
        'email': 'meera@example.com',
        'status': DonorProfileStatus.unclaimed,
        'claimedAt': null,
        'createdAt': now.subtract(const Duration(days: 18)),
        'count': 4,
        'amount': 460000
      },
      {
        'fullName': 'Rohan Desai',
        'mobile': '9812345678',
        'email': 'rohan@example.com',
        'status': DonorProfileStatus.active,
        'claimedAt': now.subtract(const Duration(days: 3)),
        'createdAt': now.subtract(const Duration(days: 30)),
        'count': 9,
        'amount': 875000
      },
      {
        'fullName': 'Naina Rao',
        'mobile': '9765432109',
        'email': 'naina@example.com',
        'status': DonorProfileStatus.deactivated,
        'claimedAt': null,
        'createdAt': now.subtract(const Duration(days: 40)),
        'count': 2,
        'amount': 230000
      },
      {
        'fullName': 'Vikram Kumar',
        'mobile': '9654321098',
        'email': 'vikram@example.com',
        'status': DonorProfileStatus.active,
        'claimedAt': now.subtract(const Duration(days: 1)),
        'createdAt': now.subtract(const Duration(days: 12)),
        'count': 15,
        'amount': 1500000
      },
      {
        'fullName': 'Sana Patil',
        'mobile': '9543210987',
        'email': 'sana@example.com',
        'status': DonorProfileStatus.merged,
        'claimedAt': null,
        'createdAt': now.subtract(const Duration(days: 60)),
        'count': 1,
        'amount': 100000
      },
      {
        'fullName': 'Kiran Joshi',
        'mobile': '9432109876',
        'email': 'kiran@example.com',
        'status': DonorProfileStatus.unclaimed,
        'claimedAt': null,
        'createdAt': now.subtract(const Duration(days: 22)),
        'count': 6,
        'amount': 720000
      },
      {
        'fullName': 'Pooja Bhatia',
        'mobile': '9321098765',
        'email': 'pooja@example.com',
        'status': DonorProfileStatus.active,
        'claimedAt': now.subtract(const Duration(days: 6)),
        'createdAt': now.subtract(const Duration(days: 9)),
        'count': 8,
        'amount': 990000
      },
      {
        'fullName': 'Aniket Sharma',
        'mobile': '9210987654',
        'email': 'aniket@example.com',
        'status': DonorProfileStatus.active,
        'claimedAt': now.subtract(const Duration(days: 10)),
        'createdAt': now.subtract(const Duration(days: 25)),
        'count': 10,
        'amount': 1120000
      },
    ];

    for (final item in seedData) {
      _donors.add(
        Donor(
          id: _uuid.v4(),
          fullName: item['fullName'] as String,
          mobile: item['mobile'] as String,
          email: item['email'] as String,
          status: item['status'] as DonorProfileStatus,
          claimedAt: item['claimedAt'] as DateTime?,
          createdAt: item['createdAt'] as DateTime,
          totalContributionsCount: item['count'] as int,
          totalConfirmedAmountPaise: item['amount'] as int,
        ),
      );
    }
  }

  @override
  Future<List<Donor>> getDonors(
      {String? search, DonorProfileStatus? status}) async {
    final normalizedSearch = search?.toLowerCase().trim() ?? '';
    final filtered = _donors.where((donor) {
      final matchesSearch = normalizedSearch.isEmpty ||
          donor.fullName.toLowerCase().contains(normalizedSearch) ||
          (donor.mobile?.toLowerCase().contains(normalizedSearch) ?? false) ||
          (donor.email?.toLowerCase().contains(normalizedSearch) ?? false);
      final matchesStatus = status == null || donor.status == status;
      return matchesSearch && matchesStatus;
    }).toList();

    return filtered
        .where((donor) => donor.status != DonorProfileStatus.merged)
        .toList();
  }

  @override
  Future<Donor?> getDonorById(String id) async {
    return _donors.where((donor) => donor.id == id).firstOrNull;
  }

  @override
  Future<Donor> createDonor({
    required String fullName,
    String? mobile,
    String? email,
    DonorProfileStatus status = DonorProfileStatus.unclaimed,
  }) async {
    final donor = Donor(
      id: _uuid.v4(),
      fullName: fullName,
      mobile: mobile,
      email: email,
      status: status,
      createdAt: DateTime.now(),
      totalContributionsCount: 0,
      totalConfirmedAmountPaise: 0,
    );
    _donors.add(donor);
    return donor;
  }

  @override
  Future<Donor?> updateDonor({
    required String id,
    String? fullName,
    String? mobile,
    String? email,
    DonorProfileStatus? status,
    DateTime? claimedAt,
  }) async {
    final index = _donors.indexWhere((donor) => donor.id == id);
    if (index == -1) return null;
    final existing = _donors[index];
    final updated = existing.copyWith(
      fullName: fullName,
      mobile: mobile,
      email: email,
      status: status,
      claimedAt: claimedAt,
    );
    _donors[index] = updated;
    return updated;
  }

  @override
  Future<Donor?> claimDonor({required String id}) async {
    return updateDonor(
      id: id,
      status: DonorProfileStatus.active,
      claimedAt: DateTime.now(),
    );
  }

  @override
  Future<bool> mergeDonor({
    required String survivingDonorId,
    required String mergedDonorId,
    required String reason,
  }) async {
    final sIndex = _donors.indexWhere((d) => d.id == survivingDonorId);
    final mIndex = _donors.indexWhere((d) => d.id == mergedDonorId);
    if (sIndex == -1 || mIndex == -1) return false;

    final surviving = _donors[sIndex];
    final merged = _donors[mIndex];

    // Combine stats without altering historical donation values
    final updatedSurviving = surviving.copyWith(
      totalContributionsCount:
          surviving.totalContributionsCount + merged.totalContributionsCount,
      totalConfirmedAmountPaise: surviving.totalConfirmedAmountPaise +
          merged.totalConfirmedAmountPaise,
    );
    _donors[sIndex] = updatedSurviving;

    // Set merged donor status to MERGED
    _donors[mIndex] = merged.copyWith(status: DonorProfileStatus.merged);
    return true;
  }

  @override
  Future<Donor> recordDonationForDonor({
    required String fullName,
    String? mobile,
    required int amountPaise,
  }) async {
    final cleanMobile = mobile?.replaceAll(RegExp(r'\D'), '') ?? '';
    final existingIndex = _donors.indexWhere((d) {
      final nameMatches = d.fullName.toLowerCase() == fullName.toLowerCase();
      final cleanDMobile = d.mobile?.replaceAll(RegExp(r'\D'), '') ?? '';
      final mobileMatches = cleanMobile.isNotEmpty &&
          cleanDMobile.isNotEmpty &&
          cleanDMobile.endsWith(cleanMobile);
      return nameMatches || mobileMatches;
    });

    if (existingIndex != -1) {
      final existing = _donors[existingIndex];
      final updated = existing.copyWith(
        totalContributionsCount: existing.totalContributionsCount + 1,
        totalConfirmedAmountPaise:
            existing.totalConfirmedAmountPaise + amountPaise,
      );
      _donors[existingIndex] = updated;
      return updated;
    }

    final newDonor = Donor(
      id: _uuid.v4(),
      fullName: fullName,
      mobile: mobile,
      status: DonorProfileStatus.active,
      createdAt: DateTime.now(),
      totalContributionsCount: 1,
      totalConfirmedAmountPaise: amountPaise,
    );
    _donors.add(newDonor);
    return newDonor;
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
