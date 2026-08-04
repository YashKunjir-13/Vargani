import 'package:dio/dio.dart';
import '../models/bill.dart';

class BillsRemoteDataSource {
  final Dio dio;

  BillsRemoteDataSource(this.dio);

  Future<List<Bill>> fetchBills() async {
    final response = await dio.get('/bills');
    final data = response.data as List<dynamic>;
    return data.map((json) => Bill.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Bill> getBillById(String id) async {
    final response = await dio.get('/bills/$id');
    return Bill.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Bill> createBill({
    required String receiverName,
    String? contact,
    required double amount,
    required String taskOrField,
    String? vendorId,
    String? milestoneId,
    String? billPhotoUrl,
  }) async {
    final response = await dio.post('/bills', data: {
      'receiverNameSnapshot': receiverName,
      'contactSnapshot': contact,
      'amount': amount,
      'date': DateTime.now().toIso8601String().split('T')[0],
      'taskOrField': taskOrField,
      if (vendorId != null) 'vendorId': vendorId,
      if (milestoneId != null) 'milestoneId': milestoneId,
      if (billPhotoUrl != null) 'billPhotoUrl': billPhotoUrl,
    });
    return Bill.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Bill> updateBill(String id, {double? amount, String? receiverName, String? taskOrField}) async {
    final response = await dio.patch('/bills/$id', data: {
      if (amount != null) 'amount': amount,
      if (receiverName != null) 'receiverNameSnapshot': receiverName,
      if (taskOrField != null) 'taskOrField': taskOrField,
    });
    return Bill.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Bill> submitBill(String id) async {
    final response = await dio.patch('/bills/$id/submit');
    return Bill.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Bill> approveBill(String id) async {
    final response = await dio.patch('/bills/$id/approve');
    return Bill.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Bill> rejectBill(String id, {required String reason}) async {
    final response = await dio.patch('/bills/$id/reject', data: {'reason': reason});
    return Bill.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Bill> markPaidBill(String id, {required BillPaymentMode paymentMode}) async {
    String modeStr;
    switch (paymentMode) {
      case BillPaymentMode.cash:
        modeStr = 'CASH';
        break;
      case BillPaymentMode.bankTransfer:
        modeStr = 'BANK_TRANSFER';
        break;
      case BillPaymentMode.upi:
        modeStr = 'UPI';
        break;
      case BillPaymentMode.cheque:
        modeStr = 'CHEQUE';
        break;
    }
    final response = await dio.patch('/bills/$id/mark-paid', data: {'paymentMode': modeStr});
    return Bill.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Bill> cancelBill(String id, {required String reason}) async {
    final response = await dio.post('/bills/$id/cancel', data: {'reason': reason});
    return Bill.fromJson(response.data as Map<String, dynamic>);
  }
}
