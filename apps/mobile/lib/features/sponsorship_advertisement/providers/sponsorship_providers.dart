import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_sponsorship_repository.dart';
import '../data/sponsorship_repository.dart';
import '../models/sponsorship.dart';

final sponsorshipRepositoryProvider = Provider<SponsorshipRepository>((ref) {
  return MockSponsorshipRepository();
});

// Search state for sponsors tab
class SponsorshipListState {
  const SponsorshipListState({this.search = ''});
  final String search;
  SponsorshipListState copyWith({String? search}) =>
      SponsorshipListState(search: search ?? this.search);
}

class SponsorshipListNotifier extends Notifier<SponsorshipListState> {
  @override
  SponsorshipListState build() => const SponsorshipListState();
  void updateSearch(String search) => state = state.copyWith(search: search);
}

final sponsorshipListControllerProvider =
    NotifierProvider<SponsorshipListNotifier, SponsorshipListState>(
  SponsorshipListNotifier.new,
);

final sponsorshipListProvider = FutureProvider<List<Sponsorship>>((ref) async {
  final repository = ref.watch(sponsorshipRepositoryProvider);
  final state = ref.watch(sponsorshipListControllerProvider);
  final all = await repository.getSponsorships();
  final query = state.search.trim().toLowerCase();
  if (query.isEmpty) return all;
  return all.where((s) {
    return s.sponsorName.toLowerCase().contains(query) ||
        (s.contactPerson?.toLowerCase().contains(query) ?? false);
  }).toList();
});

final sponsorshipDetailProvider =
    FutureProvider.family<Sponsorship?, String>((ref, id) async {
  final repository = ref.watch(sponsorshipRepositoryProvider);
  return repository.getSponsorshipById(id);
});

class SelectedSponsorshipTabNotifier extends Notifier<int> {
  @override
  int build() => 0;
  set value(int val) => state = val;
}

final selectedSponsorshipTabProvider = NotifierProvider<SelectedSponsorshipTabNotifier, int>(
  SelectedSponsorshipTabNotifier.new,
);
