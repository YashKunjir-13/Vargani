import '../models/advertisement.dart';
import 'advertisement_repository.dart';

class MockAdvertisementRepository implements AdvertisementRepository {
  final List<Advertisement> _advertisements = [
    Advertisement(
      id: 'ad-1',
      advertiserName: 'Sai Supermarket',
      type: AdvertisementType.banner,
      placementDetail: "Banner • 4'x8' • Main Gate",
      status: AdvertisementStatus.active,
      amountPaise: 1500000, // ₹15,000
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
    Advertisement(
      id: 'ad-2',
      advertiserName: 'Chintamani Jewellers',
      type: AdvertisementType.fullPage,
      placementDetail: 'Souvenir Book • Page 3',
      status: AdvertisementStatus.booked,
      amountPaise: 3000000, // ₹30,000
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
    ),
    Advertisement(
      id: 'ad-3',
      advertiserName: 'Shinde Digital Press',
      type: AdvertisementType.flexBoard,
      placementDetail: "10'x20' • Stage Backdrop",
      status: AdvertisementStatus.active,
      amountPaise: 5000000, // ₹50,000
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Advertisement(
      id: 'ad-4',
      advertiserName: 'Pawar Auto Consultants',
      type: AdvertisementType.programAd,
      placementDetail: 'Program Schedule • Quarter Page',
      status: AdvertisementStatus.pending,
      amountPaise: 1000000, // ₹10,000
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    Advertisement(
      id: 'ad-5',
      advertiserName: 'Kulkarni Textiles',
      type: AdvertisementType.booklet,
      placementDetail: 'Event Booklet • Back Cover',
      status: AdvertisementStatus.booked,
      amountPaise: 2500000, // ₹25,000
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    Advertisement(
      id: 'ad-6',
      advertiserName: 'Maharashtrian Bakery',
      type: AdvertisementType.other,
      placementDetail: 'Stall Banner • Food Court',
      status: AdvertisementStatus.pending,
      amountPaise: 800000, // ₹8,000
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Advertisement(
      id: 'ad-7',
      advertiserName: 'Deshmukh Hardware',
      type: AdvertisementType.flexBoard,
      placementDetail: "6'x12' • Parking Entrance",
      status: AdvertisementStatus.active,
      amountPaise: 1800000, // ₹18,000
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Future<List<Advertisement>> getAdvertisements() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_advertisements);
  }

  @override
  Future<Advertisement?> getAdvertisementById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _advertisements.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveAdvertisement(Advertisement advertisement) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _advertisements.indexWhere((a) => a.id == advertisement.id);
    if (index >= 0) {
      _advertisements[index] = advertisement;
    } else {
      _advertisements.add(advertisement);
    }
  }

  @override
  Future<void> markAsActive(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _advertisements.indexWhere((a) => a.id == id);
    if (index >= 0) {
      _advertisements[index] = _advertisements[index].copyWith(
        status: AdvertisementStatus.active,
      );
    }
  }
}
