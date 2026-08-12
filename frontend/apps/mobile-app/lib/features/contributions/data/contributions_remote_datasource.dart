import 'dart:io';
import 'package:dio/dio.dart';
import '../models/contribution.dart';

class ContributionsRemoteDataSource {
  final Dio dio;

  ContributionsRemoteDataSource(this.dio);

  Future<List<Contribution>> fetchContributions() async {
    final response = await dio.get('/contributions');
    final data = response.data as List<dynamic>;
    return data
        .map((json) => Contribution.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Contribution> getContributionById(String id) async {
    final response = await dio.get('/contributions/$id');
    return Contribution.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Contribution> createContribution({
    required String contributorName,
    String? contact,
    required DonationType donationType,
    String? itemDescription,
    double? weightGrams,
    double? quantity,
    String? unit,
    double? estimatedValue,
    String? notes,
    String? certificatePhotoUrl,
  }) async {
    String donationTypeStr;
    switch (donationType) {
      case DonationType.gold:
        donationTypeStr = 'Gold';
        break;
      case DonationType.silver:
        donationTypeStr = 'Silver';
        break;
      case DonationType.electronicGoods:
        donationTypeStr = 'Electronic Goods';
        break;
      case DonationType.decoration:
        donationTypeStr = 'Decoration';
        break;
      case DonationType.food:
        donationTypeStr = 'Food';
        break;
      case DonationType.musicBand:
        donationTypeStr = 'Music Band';
        break;
      case DonationType.dholPathak:
        donationTypeStr = 'Dhol Pathak';
        break;
      case DonationType.dj:
        donationTypeStr = 'DJ';
        break;
      case DonationType.other:
        donationTypeStr = 'Other';
        break;
    }

    final response = await dio.post('/contributions', data: {
      'contributorNameSnapshot': contributorName,
      'contactSnapshot': contact,
      'date': DateTime.now().toIso8601String().split('T')[0],
      'donationType': donationTypeStr,
      if (itemDescription != null) 'itemDescription': itemDescription,
      if (weightGrams != null) 'weight': weightGrams,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (estimatedValue != null) 'estimatedValue': estimatedValue,
      if (notes != null) 'notes': notes,
      if (certificatePhotoUrl != null)
        'certificatePhotoUrl': certificatePhotoUrl,
    });

    return Contribution.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Contribution> updateContribution(
    String id, {
    String? contributorName,
    String? contact,
    DonationType? donationType,
    String? itemDescription,
    double? weightGrams,
    double? quantity,
    String? unit,
    double? estimatedValue,
    String? notes,
    String? certificatePhotoUrl,
  }) async {
    final response = await dio.patch('/contributions/$id', data: {
      if (contributorName != null) 'contributorNameSnapshot': contributorName,
      if (contact != null) 'contactSnapshot': contact,
      if (itemDescription != null) 'itemDescription': itemDescription,
      if (weightGrams != null) 'weight': weightGrams,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (estimatedValue != null) 'estimatedValue': estimatedValue,
      if (notes != null) 'notes': notes,
      if (certificatePhotoUrl != null)
        'certificatePhotoUrl': certificatePhotoUrl,
    });
    return Contribution.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteContribution(String id) async {
    await dio.delete('/contributions/$id');
  }

  Future<String> uploadCertificatePhoto(File file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path,
          filename: file.path.split('/').last),
    });
    final response =
        await dio.post('/contributions/upload-certificate', data: formData);
    return response.data['url'] as String;
  }
}
