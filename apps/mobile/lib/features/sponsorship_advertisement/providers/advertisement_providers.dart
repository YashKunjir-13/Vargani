import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/advertisement_repository.dart';
import '../data/mock_advertisement_repository.dart';
import '../models/advertisement.dart';

final advertisementRepositoryProvider = Provider<AdvertisementRepository>((ref) {
  return MockAdvertisementRepository();
});

final advertisementListProvider = FutureProvider<List<Advertisement>>((ref) async {
  final repository = ref.watch(advertisementRepositoryProvider);
  return repository.getAdvertisements();
});

final advertisementDetailProvider =
    FutureProvider.family<Advertisement?, String>((ref, id) async {
  final repository = ref.watch(advertisementRepositoryProvider);
  return repository.getAdvertisementById(id);
});
