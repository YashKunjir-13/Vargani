import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
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
    String? idempotencyKey,
  }) async {
    final response = await _dio.post(
      '/payments/collect',
      options: Options(headers: {
        'X-Idempotency-Key': idempotencyKey ?? const Uuid().v4(),
      }),
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

  Future<Map<String, dynamic>> createPaymentOrder({
    required int amountPaise,
    String? donorNameSnapshot,
    String? donorId,
    String? idempotencyKey,
  }) async {
    final response = await _dio.post(
      '/payments/orders',
      data: {
        'amountPaise': amountPaise.toString(),
        if (donorNameSnapshot != null) 'donorNameSnapshot': donorNameSnapshot,
        if (donorId != null) 'donorId': donorId,
      },
      options: Options(
        headers: {
          if (idempotencyKey != null) 'X-Idempotency-Key': idempotencyKey,
        },
      ),
    );
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> processMockPayment({
    required String paymentId,
    required String outcome, // SUCCESS | FAILED | CANCELLED | PENDING
    String? idempotencyKey,
    String? reason,
  }) async {
    final response = await _dio.post(
      '/payments/mock/process',
      data: {
        'paymentId': paymentId,
        'outcome': outcome,
        if (idempotencyKey != null) 'idempotencyKey': idempotencyKey,
        if (reason != null) 'reason': reason,
      },
    );
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> cancelPayment(String paymentId,
      {String? reason}) async {
    final response = await _dio.post(
      '/payments/$paymentId/cancel',
      data: {
        if (reason != null) 'reason': reason,
      },
    );
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> retryPayment(String paymentId,
      {String? newPaymentMethod, String? idempotencyKey}) async {
    final response = await _dio.post(
      '/payments/$paymentId/retry',
      data: {
        if (newPaymentMethod != null) 'newPaymentMethod': newPaymentMethod,
        if (idempotencyKey != null) 'idempotencyKey': idempotencyKey,
      },
    );
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> getPaymentStatus(String paymentId) async {
    final response = await _dio.get('/payments/$paymentId/status');
    return Map<String, dynamic>.from(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchEvents() async {
    try {
      final response = await _dio.get('/events');
      final resData = response.data;
      List<dynamic> list = [];
      if (resData is Map && resData['data'] != null) {
        final dataObj = resData['data'];
        if (dataObj is Map && dataObj['items'] is List) {
          list = dataObj['items'] as List<dynamic>;
        } else if (dataObj is List) {
          list = dataObj;
        }
      } else if (resData is List) {
        list = resData;
      }
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchDonors(String? query) async {
    try {
      final response = await _dio.get(
        '/donors',
        queryParameters: {
          if (query != null && query.isNotEmpty) 'q': query,
        },
      );
      final resData = response.data;
      List<dynamic> list = [];
      if (resData is Map && resData['data'] != null) {
        final dataObj = resData['data'];
        if (dataObj is Map && dataObj['items'] is List) {
          list = dataObj['items'] as List<dynamic>;
        } else if (dataObj is List) {
          list = dataObj;
        }
      } else if (resData is List) {
        list = resData;
      }
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> createDonor({
    required String fullName,
    required String mobile,
    String? email,
    String? pan,
    String? address,
  }) async {
    final response = await _dio.post(
      '/donors',
      data: {
        'fullName': fullName,
        'mobile': mobile,
        if (email != null && email.isNotEmpty) 'email': email,
        if (pan != null && pan.isNotEmpty) 'pan': pan,
        if (address != null && address.isNotEmpty) 'address': address,
      },
    );
    final resData = response.data;
    if (resData is Map && resData['data'] is Map) {
      return Map<String, dynamic>.from(resData['data']);
    }
    return Map<String, dynamic>.from(response.data);
  }
}
