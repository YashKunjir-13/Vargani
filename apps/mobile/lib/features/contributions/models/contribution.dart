/// Mirrors backend DonationType (src/contributions) -- default categories
/// plus an org-configurable custom category with an Other fallback.
enum DonationType { gold, silver, electronicGoods, decoration, food, musicBand, other }

/// Mirrors backend ContributionStatus.
enum ContributionStatus { recorded, receipted }

extension DonationTypeLabel on DonationType {
  String get label => switch (this) {
        DonationType.gold => 'Gold',
        DonationType.silver => 'Silver',
        DonationType.electronicGoods => 'Electronic Goods',
        DonationType.decoration => 'Decoration',
        DonationType.food => 'Food',
        DonationType.musicBand => 'Music Band',
        DonationType.other => 'Other',
      };

  /// Gold/Silver specifically support the extra precious-metal fields.
  bool get isPreciousMetal => this == DonationType.gold || this == DonationType.silver;
}

extension ContributionStatusLabel on ContributionStatus {
  String get label => switch (this) {
        ContributionStatus.recorded => 'Recorded',
        ContributionStatus.receipted => 'Receipted',
      };
}

class Contribution {
  final String id;
  final String contributorName;
  final String? contact;
  final DateTime date;
  final DonationType donationType;
  final String? itemDescription;
  final double? weightGrams;
  final double? estimatedValue;
  final String? certificatePhotoUrl;
  final String recordedBy;
  final ContributionStatus status;

  const Contribution({
    required this.id,
    required this.contributorName,
    this.contact,
    required this.date,
    required this.donationType,
    this.itemDescription,
    this.weightGrams,
    this.estimatedValue,
    this.certificatePhotoUrl,
    required this.recordedBy,
    required this.status,
  });

  Contribution copyWith({ContributionStatus? status}) {
    return Contribution(
      id: id,
      contributorName: contributorName,
      contact: contact,
      date: date,
      donationType: donationType,
      itemDescription: itemDescription,
      weightGrams: weightGrams,
      estimatedValue: estimatedValue,
      certificatePhotoUrl: certificatePhotoUrl,
      recordedBy: recordedBy,
      status: status ?? this.status,
    );
  }
}
