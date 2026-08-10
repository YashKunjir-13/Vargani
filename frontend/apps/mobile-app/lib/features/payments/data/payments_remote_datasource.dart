import 'package:dio/dio.dart';
import '../models/payment.dart';

class PaymentsRemoteDataSource {
  final Dio _dio;

  PaymentsRemoteDataSource(this._dio);

  Future<List<Payment>> fetchPayments() async {
    final response = await _dio.get('/payments');
    final data = response.data as List<dynamic>? ?? [];
    return data
        .map((item) => Payment.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<Payment> getPaymentById(String id) async {
    final response = await _dio.get('/payments/$id');
    return Payment.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<Payment> createPayment({
    required String donorName,
    String? address,
    String? contact,
    required double amount,
    required PaymentChannel channel,
  }) async {
    final response = await _dio.post(
      '/payments',
      data: {
        'donorNameSnapshot': donorName,
        if (address != null && address.isNotEmpty) 'addressSnapshot': address,
        if (contact != null && contact.isNotEmpty) 'contactSnapshot': contact,
        'amount': amount,
        'channel': channel.toApiString,
        'paymentDateTime': DateTime.now().toIso8601String(),
      },
    );
    return Payment.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<Payment> confirmMatch(String id) async {
    final response = await _dio.patch('/payments/$id/confirm-match');
    return Payment.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<Payment> voidPayment(String id, String reason) async {
    final response = await _dio.post(
      '/payments/$id/void',
      data: {'reason': reason},
    );
    return Payment.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<Map<String, dynamic>> collectDonation({
    required String donorName,
    String? contact,
    String? address,
    required double amount,
    required String paymentMethod,
  }) async {
    final response = await _dio.post(
      '/payments/collect',
      data: {
        'donorNameSnapshot': donorName,
        if (contact != null && contact.isNotEmpty) 'contactSnapshot': contact,
        if (address != null && address.isNotEmpty) 'addressSnapshot': address,
        'amount': amount,
        'paymentMethod': paymentMethod,
      },
    );
    return Map<String, dynamic>.from(response.data);
  }
}
