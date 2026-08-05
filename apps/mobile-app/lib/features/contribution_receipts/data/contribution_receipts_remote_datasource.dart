import 'package:dio/dio.dart';
import '../models/contribution_receipt.dart';

class ContributionReceiptsRemoteDataSource {
  final Dio dio;

  ContributionReceiptsRemoteDataSource(this.dio);

  Future<List<ContributionReceipt>> fetchMyHistory() async {
    final response = await dio.get('/contribution-receipts/my-history');
    final data = response.data as List<dynamic>;
    return data.map((json) => ContributionReceipt.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<List<ContributionReceipt>> fetchAll() async {
    final response = await dio.get('/contribution-receipts');
    final data = response.data as List<dynamic>;
    return data.map((json) => ContributionReceipt.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<ContributionReceipt> getReceiptById(String id) async {
    final response = await dio.get('/contribution-receipts/$id');
    return ContributionReceipt.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ContributionReceipt> generateForContribution(String contributionId) async {
    final response = await dio.post('/contribution-receipts/generate', data: {
      'contributionId': contributionId,
    });
    return ContributionReceipt.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> resendWhatsApp(String id) async {
    await dio.post('/contribution-receipts/$id/resend-whatsapp');
  }

  Future<ContributionReceipt> voidReceipt(String id, String reason) async {
    final response = await dio.post('/contribution-receipts/$id/void', data: {
      'reason': reason,
    });
    return ContributionReceipt.fromJson(response.data as Map<String, dynamic>);
  }
}
