import '../models/advertisement.dart';
import 'advertisement_repository.dart';

class MockAdvertisementRepository implements AdvertisementRepository {
  final List<Advertisement> _advertisements = [];

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
