import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/advertisement_repository.dart';
import '../data/mock_advertisement_repository.dart';
import '../models/advertisement.dart';

final advertisementRepositoryProvider = Provider<AdvertisementRepository>((ref) {
  return MockAdvertisementRepository();
});

// Search state for advertisements tab
class AdvertisementListState {
  const AdvertisementListState({this.search = ''});
  final String search;
  AdvertisementListState copyWith({String? search}) =>
      AdvertisementListState(search: search ?? this.search);
}

class AdvertisementListNotifier extends Notifier<AdvertisementListState> {
  @override
  AdvertisementListState build() => const AdvertisementListState();
  void updateSearch(String search) => state = state.copyWith(search: search);
}

final advertisementListControllerProvider =
    NotifierProvider<AdvertisementListNotifier, AdvertisementListState>(
  AdvertisementListNotifier.new,
);

final advertisementListProvider =
    FutureProvider<List<Advertisement>>((ref) async {
  final repository = ref.watch(advertisementRepositoryProvider);
  final state = ref.watch(advertisementListControllerProvider);
  final all = await repository.getAdvertisements();
  final query = state.search.trim().toLowerCase();
  if (query.isEmpty) return all;
  return all.where((a) {
    return a.advertiserName.toLowerCase().contains(query) ||
        (a.placementDetail?.toLowerCase().contains(query) ?? false);
  }).toList();
});

final advertisementDetailProvider =
    FutureProvider.family<Advertisement?, String>((ref, id) async {
  final repository = ref.watch(advertisementRepositoryProvider);
  return repository.getAdvertisementById(id);
});
