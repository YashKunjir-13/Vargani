import 'package:dio/dio.dart';
import '../models/receipt.dart';

class ReceiptsRemoteDataSource {
  final Dio _dio;

  ReceiptsRemoteDataSource(this._dio);

  Future<List<Receipt>> fetchReceipts() async {
    final response = await _dio.get('/receipts');
    final data = response.data as List<dynamic>? ?? [];
    return data
        .map((item) => Receipt.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<Receipt>> fetchMyHistory() async {
    final response = await _dio.get('/receipts/my-history');
    final data = response.data as List<dynamic>? ?? [];
    return data
        .map((item) => Receipt.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<Receipt> getReceiptById(String id) async {
    final response = await _dio.get('/receipts/$id');
    return Receipt.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<Receipt> resendWhatsapp(String id) async {
    final response = await _dio.post('/receipts/$id/resend-whatsapp');
    return Receipt.fromJson(Map<String, dynamic>.from(response.data));
  }
}
