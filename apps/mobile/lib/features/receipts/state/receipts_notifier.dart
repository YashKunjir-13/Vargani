import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/receipts_mock_data.dart';
import '../models/receipt.dart';

/// Local, in-memory stand-in for ReceiptsService (apps/api/src/receipts).
/// generateForPayment is called exclusively by PaymentsNotifier.confirmMatch
/// -- there is no manual "create receipt" action here either, mirroring the
/// real backend's single-source-of-truth trigger.
class ReceiptsNotifier extends Notifier<List<Receipt>> {
  int _sequence = 45;

  @override
  List<Receipt> build() => buildMockReceipts();

  Receipt generateForPayment({
    required String paymentId,
    required String donorName,
    required double amount,
  }) {
    _sequence += 1;
    final receipt = Receipt(
      id: 'rcpt-${DateTime.now().microsecondsSinceEpoch}',
      receiptNumber: 'RCPT-2026-${_sequence.toString().padLeft(6, '0')}',
      paymentId: paymentId,
      donorName: donorName,
      amount: amount,
      issuedDate: DateTime.now(),
      mandalName: 'Shree Ganesh Mandal',
      status: ReceiptStatus.active,
      whatsappDeliveryStatus: WhatsappDeliveryStatus.sent,
    );
    state = [receipt, ...state];
    return receipt;
  }

  /// Retryable without regenerating the receipt -- same receiptNumber/pdfUrl.
  void resendWhatsapp(String id) {
    state = [
      for (final r in state)
        if (r.id == id)
          r.copyWith(
            whatsappDeliveryStatus: WhatsappDeliveryStatus.sent,
            whatsappRetryCount: r.whatsappRetryCount + 1,
          )
        else
          r,
    ];
  }

  void voidReceipt(String id, {required String reason}) {
    state = [
      for (final r in state)
        if (r.id == id && r.status != ReceiptStatus.voided) r.copyWith(status: ReceiptStatus.voided, voidReason: reason) else r,
    ];
  }
}

final receiptsProvider = NotifierProvider<ReceiptsNotifier, List<Receipt>>(ReceiptsNotifier.new);
