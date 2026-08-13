import 'package:uuid/uuid.dart';

import '../models/vendor.dart';
import 'vendor_repository.dart';

class MockVendorRepository implements VendorRepository {
  MockVendorRepository() {
    _vendors = _seedVendors();
  }

  late List<Vendor> _vendors;

  @override
  Future<List<Vendor>> getVendors(
      {String search = '', VendorStatus? status}) async {
    final query = search.trim().toLowerCase();
    return _vendors.where((vendor) {
      final matchesStatus = status == null || vendor.status == status;
      final haystack =
          '${vendor.name} ${vendor.contactPerson ?? ''} ${vendor.category ?? ''}'
              .toLowerCase();
      final matchesQuery = query.isEmpty || haystack.contains(query);
      return matchesStatus && matchesQuery;
    }).toList();
  }

  @override
  Future<Vendor?> getVendorById(String id) async {
    return _vendors.where((vendor) => vendor.id == id).firstOrNull;
  }

  @override
  Future<Vendor> createVendor({
    required String name,
    String? contactPerson,
    String? mobile,
    String? email,
    String? address,
    String? gstin,
    String? pan,
    String? bankAccount,
    String? bankIfsc,
    VendorStatus status = VendorStatus.active,
    String? category,
    int contractAmountPaise = 0,
    int paidAmountPaise = 0,
  }) async {
    final vendor = Vendor(
      id: const Uuid().v4(),
      name: name,
      contactPerson: contactPerson,
      mobile: mobile,
      email: email,
      address: address,
      gstin: gstin,
      pan: pan,
      bankAccount: bankAccount,
      bankIfsc: bankIfsc,
      status: status,
      createdAt: DateTime.now(),
      contractAmountPaise: contractAmountPaise,
      paidAmountPaise: paidAmountPaise,
      outstandingAmountPaise: (contractAmountPaise - paidAmountPaise)
          .clamp(0, double.maxFinite.toInt()),
      contractStatus:
          (contractAmountPaise > 0 && contractAmountPaise <= paidAmountPaise)
              ? VendorContractStatus.complete
              : VendorContractStatus.active,
      category: category,
    );
    _vendors.add(vendor);
    return vendor;
  }

  @override
  Future<Vendor?> updateVendor({
    required String id,
    String? name,
    String? contactPerson,
    String? mobile,
    String? email,
    String? address,
    String? gstin,
    String? pan,
    String? bankAccount,
    String? bankIfsc,
    VendorStatus? status,
    String? category,
    int? contractAmountPaise,
    int? paidAmountPaise,
  }) async {
    final index = _vendors.indexWhere((v) => v.id == id);
    if (index == -1) return null;
    final existing = _vendors[index];

    final newContractPaise =
        contractAmountPaise ?? existing.contractAmountPaise;
    final newPaidPaise = paidAmountPaise ?? existing.paidAmountPaise;
    final newOutstanding =
        (newContractPaise - newPaidPaise).clamp(0, double.maxFinite.toInt());

    final updated = existing.copyWith(
      name: name,
      contactPerson: contactPerson,
      mobile: mobile,
      email: email,
      address: address,
      gstin: gstin,
      pan: pan,
      bankAccount: bankAccount,
      bankIfsc: bankIfsc,
      status: status,
      category: category,
      contractAmountPaise: newContractPaise,
      paidAmountPaise: newPaidPaise,
      outstandingAmountPaise: newOutstanding,
      contractStatus: (newContractPaise > 0 && newContractPaise <= newPaidPaise)
          ? VendorContractStatus.complete
          : VendorContractStatus.active,
    );
    _vendors[index] = updated;
    return updated;
  }

  @override
  Future<Vendor?> deactivateVendor({required String id}) async {
    final index = _vendors.indexWhere((v) => v.id == id);
    if (index == -1) return null;
    final updated = _vendors[index].copyWith(
      status: VendorStatus.inactive,
      deactivatedAt: DateTime.now(),
    );
    _vendors[index] = updated;
    return updated;
  }

  @override
  Future<Vendor?> reactivateVendor({required String id}) async {
    final index = _vendors.indexWhere((v) => v.id == id);
    if (index == -1) return null;
    final updated = _vendors[index].copyWith(
      status: VendorStatus.active,
      deactivatedAt: null,
    );
    _vendors[index] = updated;
    return updated;
  }

  List<Vendor> _seedVendors() {
    return [];
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
