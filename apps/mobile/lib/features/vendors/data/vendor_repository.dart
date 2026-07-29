import '../models/vendor.dart';

abstract class VendorRepository {
  Future<List<Vendor>> getVendors({String search = '', VendorStatus? status});
  Future<Vendor?> getVendorById(String id);
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
  });
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
  });
}
