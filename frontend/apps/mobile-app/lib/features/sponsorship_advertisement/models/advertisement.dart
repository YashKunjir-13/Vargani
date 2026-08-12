enum AdvertisementType {
  banner,
  flexBoard,
  programAd,
  fullPage,
  booklet,
  other
}

extension AdvertisementTypeDisplay on AdvertisementType {
  String get label {
    return switch (this) {
      AdvertisementType.banner => 'Banner',
      AdvertisementType.flexBoard => 'Flex Board',
      AdvertisementType.programAd => 'Program Ad',
      AdvertisementType.fullPage => 'Full Page',
      AdvertisementType.booklet => 'Booklet',
      AdvertisementType.other => 'Other',
    };
  }
}

enum AdvertisementStatus { active, booked, pending }

extension AdvertisementStatusDisplay on AdvertisementStatus {
  String get label {
    return switch (this) {
      AdvertisementStatus.active => 'Active',
      AdvertisementStatus.booked => 'Booked',
      AdvertisementStatus.pending => 'Pending',
    };
  }
}

class Advertisement {
  final String id;
  final String advertiserName;
  final AdvertisementType type;
  final String? placementDetail;
  final AdvertisementStatus status;
  final int amountPaise;
  final DateTime createdAt;

  const Advertisement({
    required this.id,
    required this.advertiserName,
    required this.type,
    this.placementDetail,
    required this.status,
    required this.amountPaise,
    required this.createdAt,
  });

  Advertisement copyWith({
    String? id,
    String? advertiserName,
    AdvertisementType? type,
    String? placementDetail,
    AdvertisementStatus? status,
    int? amountPaise,
    DateTime? createdAt,
  }) {
    return Advertisement(
      id: id ?? this.id,
      advertiserName: advertiserName ?? this.advertiserName,
      type: type ?? this.type,
      placementDetail: placementDetail ?? this.placementDetail,
      status: status ?? this.status,
      amountPaise: amountPaise ?? this.amountPaise,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
