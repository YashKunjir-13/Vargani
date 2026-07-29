import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../receipts/state/receipts_notifier.dart';
import '../data/payments_mock_data.dart';
import '../models/payment.dart';

/// Local, in-memory stand-in for PaymentsService (apps/api/src/payments).
/// No network calls -- this is a UI-focused build, not wired to the API.
class PaymentsNotifier extends Notifier<List<Payment>> {
  @override
  List<Payment> build() => buildMockPayments();

  Payment create({
    required String donorName,
    String? address,
    String? contact,
    required double amount,
    required PaymentChannel channel,
    String? collectedBy,
  }) {
    final payment = Payment(
      id: 'pay-${DateTime.now().microsecondsSinceEpoch}',
      donorName: donorName,
      address: address,
      contact: contact,
      amount: amount,
      paymentDateTime: DateTime.now(),
      channel: channel,
      status: PaymentStatus.pendingMatch,
      collectedBy: collectedBy,
    );
    state = [payment, ...state];
    return payment;
  }

  /// Mirrors PaymentsService.confirmMatch: the ONLY trigger for Receipt
  /// Generation. Pending Match -> Confirmed -> Receipted happens
  /// synchronously here, exactly like the real backend's advanceToReceipted.
  void confirmMatch(String id, {required String matchedBy}) {
    final payment = state.firstWhere((p) => p.id == id);
    if (payment.status != PaymentStatus.pendingMatch) return;

    state = [
      for (final p in state)
        if (p.id == id) p.copyWith(status: PaymentStatus.receipted, matchedBy: matchedBy) else p,
    ];

    ref.read(receiptsProvider.notifier).generateForPayment(
          paymentId: id,
          donorName: payment.donorName,
          amount: payment.amount,
        );
  }

  void void_(String id, {required String reason}) {
    state = [
      for (final p in state)
        if (p.id == id && p.status != PaymentStatus.voided) p.copyWith(status: PaymentStatus.voided, voidReason: reason) else p,
    ];
  }
}

final paymentsProvider = NotifierProvider<PaymentsNotifier, List<Payment>>(PaymentsNotifier.new);
