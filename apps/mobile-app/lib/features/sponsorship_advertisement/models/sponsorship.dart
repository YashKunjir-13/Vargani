enum SponsorshipTier { gold, silver, bronze }

extension SponsorshipTierDisplay on SponsorshipTier {
  String get label {
    return switch (this) {
      SponsorshipTier.gold => 'Gold',
      SponsorshipTier.silver => 'Silver',
      SponsorshipTier.bronze => 'Bronze',
    };
  }
}

enum SponsorshipStatus { pledged, confirmed, pending }

extension SponsorshipStatusDisplay on SponsorshipStatus {
  String get label {
    return switch (this) {
      SponsorshipStatus.pledged => 'Pledged',
      SponsorshipStatus.confirmed => 'Confirmed',
      SponsorshipStatus.pending => 'Pending',
    };
  }
}

class Sponsorship {
  final String id;
  final String sponsorName;
  final String? contactPerson;
  final String? mobile;
  final SponsorshipTier tier;
  final SponsorshipStatus status;
  final int pledgedAmountPaise;
  final int confirmedAmountPaise;
  final DateTime createdAt;

  const Sponsorship({
    required this.id,
    required this.sponsorName,
    this.contactPerson,
    this.mobile,
    required this.tier,
    required this.status,
    required this.pledgedAmountPaise,
    required this.confirmedAmountPaise,
    required this.createdAt,
  });

  Sponsorship copyWith({
    String? id,
    String? sponsorName,
    String? contactPerson,
    String? mobile,
    SponsorshipTier? tier,
    SponsorshipStatus? status,
    int? pledgedAmountPaise,
    int? confirmedAmountPaise,
    DateTime? createdAt,
  }) {
    return Sponsorship(
      id: id ?? this.id,
      sponsorName: sponsorName ?? this.sponsorName,
      contactPerson: contactPerson ?? this.contactPerson,
      mobile: mobile ?? this.mobile,
      tier: tier ?? this.tier,
      status: status ?? this.status,
      pledgedAmountPaise: pledgedAmountPaise ?? this.pledgedAmountPaise,
      confirmedAmountPaise: confirmedAmountPaise ?? this.confirmedAmountPaise,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
