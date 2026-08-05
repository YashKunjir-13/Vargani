import 'package:uuid/uuid.dart';

import '../models/vendor.dart';
import 'vendor_repository.dart';

class MockVendorRepository implements VendorRepository {
  MockVendorRepository() {
    _vendors = _seedVendors();
  }

  late List<Vendor> _vendors;

  @override
  Future<List<Vendor>> getVendors({String search = '', VendorStatus? status}) async {
    final query = search.trim().toLowerCase();
    return _vendors.where((vendor) {
      final matchesStatus = status == null || vendor.status == status;
      final haystack =
          '${vendor.name} ${vendor.contactPerson ?? ''} ${vendor.category ?? ''}'.toLowerCase();
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
      outstandingAmountPaise: (contractAmountPaise - paidAmountPaise).clamp(0, double.maxFinite.toInt()),
      contractStatus: (contractAmountPaise > 0 && contractAmountPaise <= paidAmountPaise)
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

    final newContractPaise = contractAmountPaise ?? existing.contractAmountPaise;
    final newPaidPaise = paidAmountPaise ?? existing.paidAmountPaise;
    final newOutstanding = (newContractPaise - newPaidPaise).clamp(0, double.maxFinite.toInt());

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
    return [
      Vendor(
        id: 'vendor-1',
        name: 'Mahalaxmi Mandap Decorators',
        contactPerson: 'Suresh Patil',
        mobile: '9876543210',
        email: 'info@mahalaxmimandap.com',
        address: 'Plot 45, MIDC Area, Thane West, Mumbai',
        gstin: '27AAAAA0000A1Z5',
        pan: 'ABCDE1234F',
        bankAccount: '987654321012',
        bankIfsc: 'SBIN0001234',
        status: VendorStatus.active,
        createdAt: DateTime(2025, 1, 15),
        contractAmountPaise: 45000000,
        paidAmountPaise: 30000000,
        outstandingAmountPaise: 15000000,
        contractStatus: VendorContractStatus.active,
        category: 'Mandap & Decoration',
      ),
      Vendor(
        id: 'vendor-2',
        name: 'Shree Sound Systems & Lighting',
        contactPerson: 'Ramesh Sawant',
        mobile: '9123456780',
        email: 'shreesound@gmail.com',
        address: 'Shop 12, Station Road, Dadar, Mumbai',
        gstin: '27BBBBB1111B2Z6',
        pan: 'BCDEF2345G',
        bankAccount: '112233445566',
        bankIfsc: 'HDFC0005678',
        status: VendorStatus.active,
        createdAt: DateTime(2025, 2, 1),
        contractAmountPaise: 18000000,
        paidAmountPaise: 18000000,
        outstandingAmountPaise: 0,
        contractStatus: VendorContractStatus.complete,
        category: 'Sound & Lighting',
      ),
      Vendor(
        id: 'vendor-3',
        name: 'Annapurna Catering Services',
        contactPerson: 'Sunita Joshi',
        mobile: '9988776655',
        email: 'annapurnacaterers@outlook.com',
        address: 'B-7 Gokhale Road, Girgaon, Mumbai',
        gstin: '27CCCCC2222C3Z7',
        pan: 'CDEFG3456H',
        bankAccount: '556677889900',
        bankIfsc: 'ICIC0009012',
        status: VendorStatus.inactive,
        deactivatedAt: DateTime(2025, 3, 10),
        createdAt: DateTime(2025, 1, 20),
        contractAmountPaise: 25000000,
        paidAmountPaise: 15000000,
        outstandingAmountPaise: 10000000,
        contractStatus: VendorContractStatus.active,
        category: 'Prasad & Catering',
      ),
    ];
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
