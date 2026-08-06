import '../models/sponsorship.dart';
import 'sponsorship_repository.dart';

class MockSponsorshipRepository implements SponsorshipRepository {
  final List<Sponsorship> _sponsorships = [
    Sponsorship(
      id: 'spon-1',
      sponsorName: 'Patil Motors Pvt. Ltd.',
      contactPerson: 'Sanjay Patil',
      mobile: '9822012345',
      tier: SponsorshipTier.gold,
      status: SponsorshipStatus.confirmed,
      pledgedAmountPaise: 25000000, // ₹2,50,000
      confirmedAmountPaise: 25000000, // ₹2,50,000
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    Sponsorship(
      id: 'spon-2',
      sponsorName: 'Desai Jewellers',
      contactPerson: 'Anil Desai',
      mobile: '9890123456',
      tier: SponsorshipTier.gold,
      status: SponsorshipStatus.pledged,
      pledgedAmountPaise: 15000000, // ₹1,50,000
      confirmedAmountPaise: 0,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Sponsorship(
      id: 'spon-3',
      sponsorName: 'Sai Supermarket',
      contactPerson: 'Vikas Shinde',
      mobile: '9422034567',
      tier: SponsorshipTier.silver,
      status: SponsorshipStatus.confirmed,
      pledgedAmountPaise: 7500000, // ₹75,000
      confirmedAmountPaise: 7500000, // ₹75,000
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    Sponsorship(
      id: 'spon-4',
      sponsorName: 'Krushi Agro Industries',
      contactPerson: 'Ramesh Kadam',
      mobile: '9765045678',
      tier: SponsorshipTier.silver,
      status: SponsorshipStatus.pledged,
      pledgedAmountPaise: 5000000, // ₹50,000
      confirmedAmountPaise: 0,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Sponsorship(
      id: 'spon-5',
      sponsorName: 'Kadam Sweets & Caterers',
      contactPerson: 'Prakash Kadam',
      mobile: '9823056789',
      tier: SponsorshipTier.bronze,
      status: SponsorshipStatus.pending,
      pledgedAmountPaise: 2500000, // ₹25,000
      confirmedAmountPaise: 0,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    Sponsorship(
      id: 'spon-6',
      sponsorName: 'More Transport Corp',
      contactPerson: 'Mahesh More',
      mobile: '9921067890',
      tier: SponsorshipTier.silver,
      status: SponsorshipStatus.pending,
      pledgedAmountPaise: 4000000, // ₹40,000
      confirmedAmountPaise: 0,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Sponsorship(
      id: 'spon-7',
      sponsorName: 'Joshi Electricals',
      contactPerson: 'Ganesh Joshi',
      mobile: '9881078901',
      tier: SponsorshipTier.bronze,
      status: SponsorshipStatus.confirmed,
      pledgedAmountPaise: 2000000, // ₹20,000
      confirmedAmountPaise: 2000000, // ₹20,000
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

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
