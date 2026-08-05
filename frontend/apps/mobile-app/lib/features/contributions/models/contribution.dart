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

  factory Contribution.fromJson(Map<String, dynamic> json) {
    DonationType parseDonationType(String? typeStr) {
      switch (typeStr?.toLowerCase()) {
        case 'gold':
          return DonationType.gold;
        case 'silver':
          return DonationType.silver;
        case 'electronic goods':
        case 'electronicgoods':
          return DonationType.electronicGoods;
        case 'decoration':
          return DonationType.decoration;
        case 'food':
          return DonationType.food;
        case 'music band':
        case 'musicband':
          return DonationType.musicBand;
        default:
          return DonationType.other;
      }
    }

    ContributionStatus parseStatus(String? statusStr) {
      switch (statusStr?.toUpperCase()) {
        case 'RECORDED':
          return ContributionStatus.recorded;
        case 'RECEIPTED':
          return ContributionStatus.receipted;
        default:
          return ContributionStatus.recorded;
      }
    }

    final rawWeight = json['weight'] ?? json['weightGrams'];
    final double? weightVal = rawWeight != null ? (rawWeight is num ? rawWeight.toDouble() : double.tryParse(rawWeight.toString())) : null;

    final rawEst = json['estimatedValue'];
    final double? estVal = rawEst != null ? (rawEst is num ? rawEst.toDouble() : double.tryParse(rawEst.toString())) : null;

    return Contribution(
      id: json['id'] as String? ?? '',
      contributorName: json['contributorNameSnapshot'] as String? ?? json['contributorName'] as String? ?? '',
      contact: json['contactSnapshot'] as String? ?? json['contact'] as String?,
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
      donationType: parseDonationType(json['donationType'] as String?),
      itemDescription: json['itemDescription'] as String?,
      weightGrams: weightVal,
      estimatedValue: estVal,
      certificatePhotoUrl: json['certificatePhotoUrl'] as String?,
      recordedBy: json['recordedBy'] as String? ?? '',
      status: parseStatus(json['status'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    String donationTypeToString(DonationType type) {
      switch (type) {
        case DonationType.gold:
          return 'Gold';
        case DonationType.silver:
          return 'Silver';
        case DonationType.electronicGoods:
          return 'Electronic Goods';
        case DonationType.decoration:
          return 'Decoration';
        case DonationType.food:
          return 'Food';
        case DonationType.musicBand:
          return 'Music Band';
        case DonationType.other:
          return 'Other';
      }
    }

    return {
      'id': id,
      'contributorNameSnapshot': contributorName,
      'contactSnapshot': contact,
      'date': date.toIso8601String().split('T')[0],
      'donationType': donationTypeToString(donationType),
      'itemDescription': itemDescription,
      'weight': weightGrams,
      'estimatedValue': estimatedValue,
      'certificatePhotoUrl': certificatePhotoUrl,
      'status': status == ContributionStatus.recorded ? 'RECORDED' : 'RECEIPTED',
    };
  }

  Contribution copyWith({
    ContributionStatus? status,
    String? contributorName,
    String? contact,
    DonationType? donationType,
    String? itemDescription,
    double? weightGrams,
    double? estimatedValue,
    String? certificatePhotoUrl,
  }) {
    return Contribution(
      id: id,
      contributorName: contributorName ?? this.contributorName,
      contact: contact ?? this.contact,
      date: date,
      donationType: donationType ?? this.donationType,
      itemDescription: itemDescription ?? this.itemDescription,
      weightGrams: weightGrams ?? this.weightGrams,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      certificatePhotoUrl: certificatePhotoUrl ?? this.certificatePhotoUrl,
      recordedBy: recordedBy,
      status: status ?? this.status,
    );
  }
}

