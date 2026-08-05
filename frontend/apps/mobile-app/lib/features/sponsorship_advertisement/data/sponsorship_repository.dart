import '../models/sponsorship.dart';

abstract class SponsorshipRepository {
  Future<List<Sponsorship>> getSponsorships();
  Future<Sponsorship?> getSponsorshipById(String id);
  Future<void> saveSponsorship(Sponsorship sponsorship);
  Future<void> markAsConfirmed(String id);
}
