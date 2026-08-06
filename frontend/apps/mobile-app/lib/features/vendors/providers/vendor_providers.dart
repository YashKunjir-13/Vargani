import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_vendor_repository.dart';
import '../data/vendor_repository.dart';
import '../models/vendor.dart';

final vendorRepositoryProvider =
    Provider<VendorRepository>((ref) => MockVendorRepository());

class VendorListState {
  const VendorListState({this.search = '', this.status});

  final String search;
  final VendorStatus? status;

  VendorListState copyWith({String? search, VendorStatus? status}) {
    return VendorListState(
      search: search ?? this.search,
      status: status ?? this.status,
    );
  }
}

class VendorListNotifier extends Notifier<VendorListState> {
  @override
  VendorListState build() => const VendorListState();

  void updateSearch(String search) {
    state = state.copyWith(search: search);
  }

  void updateStatus(VendorStatus? status) {
    state = state.copyWith(status: status);
  }
}

final vendorListControllerProvider =
    NotifierProvider<VendorListNotifier, VendorListState>(
  VendorListNotifier.new,
);

final vendorListProvider = FutureProvider<List<Vendor>>((ref) async {
  final state = ref.watch(vendorListControllerProvider);
  final repository = ref.watch(vendorRepositoryProvider);
  return repository.getVendors(search: state.search, status: state.status);
});

final vendorDetailProvider =
    FutureProvider.family<Vendor?, String>((ref, vendorId) async {
  final repository = ref.watch(vendorRepositoryProvider);
  return repository.getVendorById(vendorId);
});
