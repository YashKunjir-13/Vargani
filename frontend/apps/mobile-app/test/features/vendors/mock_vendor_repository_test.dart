import 'package:flutter_test/flutter_test.dart';
import 'package:pauti_pustak_mobile/features/vendors/data/mock_vendor_repository.dart';
import 'package:pauti_pustak_mobile/features/vendors/models/vendor.dart';

void main() {
  late MockVendorRepository repository;

  setUp(() {
    repository = MockVendorRepository();
  });

  test('returns filtered vendors and computes derived totals', () async {
    await repository.createVendor(
      name: 'Decor Vendor',
      category: 'Mandap & Decoration',
      contractAmountPaise: 1000000,
      paidAmountPaise: 500000,
      status: VendorStatus.active,
    );
    final vendors = await repository.getVendors(search: 'decor');

    expect(vendors, isNotEmpty);
    expect(vendors.any((vendor) => vendor.category == 'Mandap & Decoration'), isTrue);
    expect(vendors.first.contractAmountPaise, greaterThan(0));
    expect(vendors.first.outstandingAmountPaise, greaterThanOrEqualTo(0));
  });

  test('creates and updates vendors with derived contract values', () async {
    final created = await repository.createVendor(
      name: 'New Vendor',
      category: 'Security',
      contractAmountPaise: 2500000,
      paidAmountPaise: 1000000,
      status: VendorStatus.active,
    );

    expect(created.name, 'New Vendor');
    expect(created.outstandingAmountPaise, 1500000);

    final updated = await repository.updateVendor(
      id: created.id,
      paidAmountPaise: 2500000,
    );

    expect(updated, isNotNull);
    expect(updated!.outstandingAmountPaise, 0);
    expect(updated.contractStatus, VendorContractStatus.complete);
  });
}
