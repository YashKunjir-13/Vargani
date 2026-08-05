import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pauti_pustak_mobile/core/session/session_controller.dart';

import '../data/payments_remote_datasource.dart';
import '../models/payment.dart';
import '../../receipts/models/receipt.dart';
import '../../receipts/state/receipts_notifier.dart';

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
      if (!ref.mounted) return;
      if (list.isNotEmpty) {
        state = AsyncValue.data(list);
      }
    } catch (_) {
      if (!ref.mounted) return;
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
      final offlinePayment = Payment(
        id: 'pay-${DateTime.now().microsecondsSinceEpoch}',
        donorName: donorName,
        address: address,
        contact: contact,
        amount: amount,
        channel: channel,
        paymentDateTime: DateTime.now(),
        status: PaymentStatus.pendingMatch,
      );
      final currentList = state.value ?? [];
      state = AsyncValue.data([...currentList, offlinePayment]);
      return offlinePayment;
    }
  }

  Future<bool> confirmMatch(String id, {String? matchedBy}) async {
    try {
      final dataSource = ref.read(paymentsRemoteDataSourceProvider);
      await dataSource.confirmMatch(id);
      await loadPayments();
      return true;
    } catch (e) {
      final currentList = state.value ?? [];
      final matchPayment = currentList.firstWhere((p) => p.id == id);
      
      // Update local payment state
      state = AsyncValue.data([
        for (final p in currentList)
          if (p.id == id)
            Payment(
              id: p.id,
              donorName: p.donorName,
              address: p.address,
              contact: p.contact,
              amount: p.amount,
              channel: p.channel,
              paymentDateTime: p.paymentDateTime,
              status: PaymentStatus.receipted,
            )
          else
            p
      ]);

      // Auto-generate receipt for offline fallback
      final receiptsNotifier = ref.read(receiptsProvider.notifier);
      final currentReceipts = receiptsNotifier.state.value ?? [];
      final offlineReceipt = Receipt(
        id: 'rcpt-${DateTime.now().microsecondsSinceEpoch}',
        receiptNumber: 'RCPT-2026-${(currentReceipts.length + 1).toString().padLeft(6, '0')}',
        paymentId: id,
        donorName: matchPayment.donorName,
        amount: matchPayment.amount,
        issuedDate: DateTime.now(),
        mandalName: 'Shree Siddhivinayak Ganpati Mandal',
        status: ReceiptStatus.active,
        whatsappDeliveryStatus: WhatsappDeliveryStatus.sent,
      );
      receiptsNotifier.state = AsyncValue.data([...currentReceipts, offlineReceipt]);
      return true;
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
