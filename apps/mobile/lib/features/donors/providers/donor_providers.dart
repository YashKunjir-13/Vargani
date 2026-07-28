import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/donor_repository.dart';
import '../data/mock_donor_repository.dart';
import '../models/donor.dart';

final donorRepositoryProvider = Provider<DonorRepository>((ref) => MockDonorRepository());

class DonorListState {
  const DonorListState({this.search = '', this.status});

  final String search;
  final DonorProfileStatus? status;

  DonorListState copyWith({String? search, DonorProfileStatus? status}) {
    return DonorListState(
      search: search ?? this.search,
      status: status ?? this.status,
    );
  }
}

class DonorListController extends StateNotifier<DonorListState> {
  DonorListController() : super(const DonorListState());

  void updateSearch(String search) {
    state = state.copyWith(search: search);
  }

  void updateStatus(DonorProfileStatus? status) {
    state = state.copyWith(status: status);
  }
}

final donorListControllerProvider = StateNotifierProvider<DonorListController, DonorListState>(
  (ref) => DonorListController(),
);

final donorListProvider = FutureProvider<List<Donor>>((ref) async {
  final state = ref.watch(donorListControllerProvider);
  final repository = ref.watch(donorRepositoryProvider);
  return repository.getDonors(search: state.search, status: state.status);
});

final donorDetailProvider = FutureProvider.family<Donor?, String>((ref, donorId) async {
  final repository = ref.watch(donorRepositoryProvider);
  return repository.getDonorById(donorId);
});
