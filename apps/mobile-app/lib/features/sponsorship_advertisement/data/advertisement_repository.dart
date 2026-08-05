import '../models/advertisement.dart';

abstract class AdvertisementRepository {
  Future<List<Advertisement>> getAdvertisements();
  Future<Advertisement?> getAdvertisementById(String id);
  Future<void> saveAdvertisement(Advertisement advertisement);
  Future<void> markAsActive(String id);
}
