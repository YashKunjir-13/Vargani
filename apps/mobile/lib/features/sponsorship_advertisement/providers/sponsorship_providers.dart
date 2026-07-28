import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_sponsorship_repository.dart';
import '../data/sponsorship_repository.dart';
import '../models/sponsorship.dart';

final sponsorshipRepositoryProvider = Provider<SponsorshipRepository>((ref) {
  return MockSponsorshipRepository();
});

final sponsorshipListProvider = FutureProvider<List<Sponsorship>>((ref) async {
  final repository = ref.watch(sponsorshipRepositoryProvider);
  return repository.getSponsorships();
});

final sponsorshipDetailProvider =
    FutureProvider.family<Sponsorship?, String>((ref, id) async {
  final repository = ref.watch(sponsorshipRepositoryProvider);
  return repository.getSponsorshipById(id);
});

final selectedSponsorshipTabProvider = StateProvider<int>((ref) => 0);
