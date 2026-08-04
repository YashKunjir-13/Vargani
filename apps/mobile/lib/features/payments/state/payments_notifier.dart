import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pauti_pustak_mobile/core/session/session_controller.dart';

import '../data/payments_remote_datasource.dart';
import '../models/payment.dart';

import '../data/payments_mock_data.dart';

final paymentsRemoteDataSourceProvider = Provider<PaymentsRemoteDataSource>((ref) {
  return PaymentsRemoteDataSource(ref.watch(dioProvider));
});

class PaymentsNotifier extends Notifier<AsyncValue<List<Payment>>> {
  @override
  AsyncValue<List<Payment>> build() {
    loadPayments();
    return AsyncValue.data(buildMockPayments());
  }

  Future<void> loadPayments() async {
    try {
      final dataSource = ref.read(paymentsRemoteDataSourceProvider);
      final list = await dataSource.fetchPayments();
      if (list.isNotEmpty) {
        state = AsyncValue.data(list);
      }
    } catch (_) {
      if (state.value == null || state.value!.isEmpty) {
        state = AsyncValue.data(buildMockPayments());
      }
    }
  }

  Future<Payment?> create({
    required String donorName,
    String? address,
    String? contact,
    required double amount,
    required PaymentChannel channel,
    String? collectedBy,
  }) async {
    try {
      final dataSource = ref.read(paymentsRemoteDataSourceProvider);
      final created = await dataSource.createPayment(
        donorName: donorName,
        address: address,
        contact: contact,
        amount: amount,
        channel: channel,
      );
      await loadPayments();
      return created;
    } catch (e) {
      return null;
    }
  }

  Future<bool> confirmMatch(String id, {String? matchedBy}) async {
    try {
      final dataSource = ref.read(paymentsRemoteDataSourceProvider);
      await dataSource.confirmMatch(id);
      await loadPayments();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> void_(String id, {required String reason}) async {
    try {
      final dataSource = ref.read(paymentsRemoteDataSourceProvider);
      await dataSource.voidPayment(id, reason);
      await loadPayments();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final paymentsProvider = NotifierProvider<PaymentsNotifier, AsyncValue<List<Payment>>>(PaymentsNotifier.new);
