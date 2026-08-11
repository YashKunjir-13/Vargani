import '../models/sponsorship.dart';
import 'sponsorship_repository.dart';

class MockSponsorshipRepository implements SponsorshipRepository {
  final List<Sponsorship> _sponsorships = [];

  @override
  Future<List<Sponsorship>> getSponsorships() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_sponsorships);
  }

  @override
  Future<Sponsorship?> getSponsorshipById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _sponsorships.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveSponsorship(Sponsorship sponsorship) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _sponsorships.indexWhere((s) => s.id == sponsorship.id);
    if (index >= 0) {
      _sponsorships[index] = sponsorship;
    } else {
      _sponsorships.add(sponsorship);
    }
  }

  @override
  Future<void> markAsConfirmed(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _sponsorships.indexWhere((s) => s.id == id);
    if (index >= 0) {
      final existing = _sponsorships[index];
      // Note: Real confirmation would tie into actual Contributions/Collections backend modules.
      _sponsorships[index] = existing.copyWith(
        status: SponsorshipStatus.confirmed,
        confirmedAmountPaise: existing.pledgedAmountPaise,
      );
    }
  }
}
