import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/contribution_receipts_mock_data.dart';
import '../models/contribution_receipt.dart';

/// Local, in-memory stand-in for ContributionReceiptsService
/// (src/contribution-receipts). Deliberately has its OWN _sequence counter,
/// entirely separate from ReceiptsNotifier's -- CRCPT-2026-000001 and
/// RCPT-2026-000045 can and do coexist in the same organizationId+
/// festivalYear without ever colliding, because they are two independent
/// atomic counters, not one shared one.
class ContributionReceiptsNotifier extends Notifier<List<ContributionReceipt>> {
  int _sequence = 3;

  @override
  List<ContributionReceipt> build() => buildMockContributionReceipts();

  /// The record action itself produces the receipt -- there is no separate
  /// manual "generate" step, unlike the monetary Payment -> confirmMatch
  /// flow. Called exclusively by ContributionsNotifier.record.
  ContributionReceipt generateForContribution({
    required String contributionId,
    required String contributorName,
    required String donationType,
    String? templateVersionId,
  }) {
    _sequence += 1;
    final receipt = ContributionReceipt(
      id: 'crcpt-${DateTime.now().microsecondsSinceEpoch}',
      contributionReceiptNumber: 'CRCPT-2026-${_sequence.toString().padLeft(6, '0')}',
      contributionId: contributionId,
      contributorName: contributorName,
      donationType: donationType,
      issuedDate: DateTime.now(),
      mandalName: 'Shree Ganesh Mandal',
      templateVersionId: templateVersionId,
      status: ContributionReceiptStatus.active,
      whatsappDeliveryStatus: ContributionReceiptWhatsappStatus.sent,
    );
    state = [receipt, ...state];
    return receipt;
  }

  void resendWhatsapp(String id) {
    state = [
      for (final r in state)
        if (r.id == id)
          r.copyWith(
            whatsappDeliveryStatus: ContributionReceiptWhatsappStatus.sent,
            whatsappRetryCount: r.whatsappRetryCount + 1,
          )
        else
          r,
    ];
  }

  void voidReceipt(String id, {required String reason}) {
    state = [
      for (final r in state)
        if (r.id == id && r.status != ContributionReceiptStatus.voided)
          r.copyWith(status: ContributionReceiptStatus.voided, voidReason: reason)
        else
          r,
    ];
  }
}

final contributionReceiptsProvider =
    NotifierProvider<ContributionReceiptsNotifier, List<ContributionReceipt>>(ContributionReceiptsNotifier.new);
