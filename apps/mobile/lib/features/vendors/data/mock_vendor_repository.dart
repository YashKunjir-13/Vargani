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
      final haystack = [vendor.name, vendor.category, vendor.contactPerson]
          .whereType<String>()
          .join(' ')
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
      status: status,
      createdAt: DateTime.now(),
      contractAmountPaise: contractAmountPaise,
      paidAmountPaise: paidAmountPaise,
      outstandingAmountPaise: contractAmountPaise - paidAmountPaise,
      contractStatus:
          _deriveContractStatus(contractAmountPaise, paidAmountPaise),
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
    VendorStatus? status,
    String? category,
    int? contractAmountPaise,
    int? paidAmountPaise,
  }) async {
    final index = _vendors.indexWhere((vendor) => vendor.id == id);
    if (index == -1) {
      return null;
    }

    final existing = _vendors[index];
    final nextContract = contractAmountPaise ?? existing.contractAmountPaise;
    final nextPaid = paidAmountPaise ?? existing.paidAmountPaise;
    final updated = existing.copyWith(
      name: name,
      contactPerson: contactPerson,
      mobile: mobile,
      email: email,
      address: address,
      status: status,
      category: category,
      contractAmountPaise: nextContract,
      paidAmountPaise: nextPaid,
      outstandingAmountPaise: nextContract - nextPaid,
      contractStatus: _deriveContractStatus(nextContract, nextPaid),
    );
    _vendors[index] = updated;
    return updated;
  }

  List<Vendor> _seedVendors() {
    return [
      Vendor(
        id: 'vendor-1',
        name: 'Rajat Decor',
        contactPerson: 'Rajat Sharma',
        mobile: '9876543210',
        email: 'rajat@decor.in',
        address: 'Pune',
        status: VendorStatus.active,
        createdAt: DateTime(2024, 7, 2),
        contractAmountPaise: 18000000,
        paidAmountPaise: 9000000,
        outstandingAmountPaise: 9000000,
        contractStatus: VendorContractStatus.active,
        category: 'Decoration',
      ),
      Vendor(
        id: 'vendor-2',
        name: 'Sonic Wave',
        contactPerson: 'Asha Mehta',
        mobile: '9123456780',
        email: 'asha@sonicwave.in',
        address: 'Mumbai',
        status: VendorStatus.active,
        createdAt: DateTime(2024, 6, 15),
        contractAmountPaise: 25000000,
        paidAmountPaise: 25000000,
        outstandingAmountPaise: 0,
        contractStatus: VendorContractStatus.complete,
        category: 'DJ/Sound',
      ),
      Vendor(
        id: 'vendor-3',
        name: 'Maharaj Catering',
        contactPerson: 'Vikas Rao',
        mobile: '9988776655',
        email: 'vikas@maharaj.in',
        address: 'Nashik',
        status: VendorStatus.active,
        createdAt: DateTime(2024, 8, 1),
        contractAmountPaise: 32000000,
        paidAmountPaise: 15000000,
        outstandingAmountPaise: 17000000,
        contractStatus: VendorContractStatus.pending,
        category: 'Food',
      ),
      Vendor(
        id: 'vendor-4',
        name: 'Shield Security',
        contactPerson: 'Nilesh Patil',
        mobile: '9090909090',
        email: 'nilesh@shield.in',
        address: 'Nagpur',
        status: VendorStatus.active,
        createdAt: DateTime(2024, 5, 22),
        contractAmountPaise: 14000000,
        paidAmountPaise: 14000000,
        outstandingAmountPaise: 0,
        contractStatus: VendorContractStatus.complete,
        category: 'Security',
      ),
      Vendor(
        id: 'vendor-5',
        name: 'Bright Lights',
        contactPerson: 'Kavita Joshi',
        mobile: '9871234567',
        email: 'kavita@brightlights.in',
        address: 'Pune',
        status: VendorStatus.active,
        createdAt: DateTime(2024, 9, 11),
        contractAmountPaise: 9000000,
        paidAmountPaise: 3000000,
        outstandingAmountPaise: 6000000,
        contractStatus: VendorContractStatus.active,
        category: 'Lighting',
      ),
      Vendor(
        id: 'vendor-6',
        name: 'Green Valley Flowers',
        contactPerson: 'Pooja Deshmukh',
        mobile: '9011223344',
        email: 'pooja@gvflowers.in',
        address: 'Kolhapur',
        status: VendorStatus.active,
        createdAt: DateTime(2024, 10, 3),
        contractAmountPaise: 6000000,
        paidAmountPaise: 4000000,
        outstandingAmountPaise: 2000000,
        contractStatus: VendorContractStatus.pending,
        category: 'Floral',
      ),
      Vendor(
        id: 'vendor-7',
        name: 'Metro Transit',
        contactPerson: 'Anand Kulkarni',
        mobile: '9812345678',
        email: 'anand@metrotransit.in',
        address: 'Pune',
        status: VendorStatus.inactive,
        createdAt: DateTime(2024, 4, 17),
        contractAmountPaise: 5000000,
        paidAmountPaise: 5000000,
        outstandingAmountPaise: 0,
        contractStatus: VendorContractStatus.complete,
        category: 'Transport',
      ),
      Vendor(
        id: 'vendor-8',
        name: 'Elite Stage Setup',
        contactPerson: 'Sameer Bhosale',
        mobile: '7777777777',
        email: 'sameer@elitestage.in',
        address: 'Aurangabad',
        status: VendorStatus.active,
        createdAt: DateTime(2024, 3, 9),
        contractAmountPaise: 22000000,
        paidAmountPaise: 5500000,
        outstandingAmountPaise: 16500000,
        contractStatus: VendorContractStatus.active,
        category: 'Stage Setup',
      ),
      Vendor(
        id: 'vendor-9',
        name: 'Prakash Electricals',
        contactPerson: 'Rina Shah',
        mobile: '8888888888',
        email: 'rina@prakashelectricals.in',
        address: 'Mumbai',
        status: VendorStatus.active,
        createdAt: DateTime(2024, 2, 20),
        contractAmountPaise: 11000000,
        paidAmountPaise: 6000000,
        outstandingAmountPaise: 5000000,
        contractStatus: VendorContractStatus.pending,
        category: 'Electrical',
      ),
      Vendor(
        id: 'vendor-10',
        name: 'Royal Printworks',
        contactPerson: 'Rohit Kale',
        mobile: '9555666777',
        email: 'rohit@royalprint.in',
        address: 'Pune',
        status: VendorStatus.active,
        createdAt: DateTime(2024, 1, 12),
        contractAmountPaise: 7000000,
        paidAmountPaise: 7000000,
        outstandingAmountPaise: 0,
        contractStatus: VendorContractStatus.complete,
        category: 'Print',
      ),
    ];
  }

  VendorContractStatus _deriveContractStatus(
      int contractAmountPaise, int paidAmountPaise) {
    if (paidAmountPaise >= contractAmountPaise) {
      return VendorContractStatus.complete;
    }
    if (paidAmountPaise <= 0) {
      return VendorContractStatus.pending;
    }
    return VendorContractStatus.active;
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
