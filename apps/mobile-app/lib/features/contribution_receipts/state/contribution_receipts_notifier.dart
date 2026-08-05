import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/session/session_controller.dart';
import '../data/contribution_receipts_mock_data.dart';
import '../data/contribution_receipts_remote_datasource.dart';
import '../models/contribution_receipt.dart';

final contributionReceiptsRemoteDataSourceProvider = Provider<ContributionReceiptsRemoteDataSource?>((ref) {
  try {
    final dio = ref.watch(dioProvider);
    return ContributionReceiptsRemoteDataSource(dio);
  } catch (_) {
    return null;
  }
});

class ContributionReceiptsNotifier extends Notifier<List<ContributionReceipt>> {
  int _sequence = 3;

  @override
  List<ContributionReceipt> build() => buildMockContributionReceipts();

  Future<void> fetchMyHistory() async {
    final remote = ref.read(contributionReceiptsRemoteDataSourceProvider);
    if (remote == null) return;
    try {
      final history = await remote.fetchMyHistory();
      state = history;
    } catch (_) {}
  }

  Future<void> fetchAll() async {
    final remote = ref.read(contributionReceiptsRemoteDataSourceProvider);
    if (remote == null) return;
    try {
      final all = await remote.fetchAll();
      state = all;
    } catch (_) {}
  }

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

    _generateRemote(contributionId);

    return receipt;
  }

  Future<void> _generateRemote(String contributionId) async {
    final remote = ref.read(contributionReceiptsRemoteDataSourceProvider);
    if (remote == null) return;
    try {
      final generated = await remote.generateForContribution(contributionId);
      state = [
        for (final r in state) if (r.contributionId == contributionId) generated else r,
      ];
    } catch (_) {}
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
    _resendWhatsappRemote(id);
  }

  Future<void> _resendWhatsappRemote(String id) async {
    final remote = ref.read(contributionReceiptsRemoteDataSourceProvider);
    if (remote == null) return;
    try {
      await remote.resendWhatsApp(id);
    } catch (_) {}
  }

  void voidReceipt(String id, {required String reason}) {
    state = [
      for (final r in state)
        if (r.id == id && r.status != ContributionReceiptStatus.voided)
          r.copyWith(status: ContributionReceiptStatus.voided, voidReason: reason)
        else
          r,
    ];
    _voidReceiptRemote(id, reason);
  }

  Future<void> _voidReceiptRemote(String id, String reason) async {
    final remote = ref.read(contributionReceiptsRemoteDataSourceProvider);
    if (remote == null) return;
    try {
      final voided = await remote.voidReceipt(id, reason);
      state = [for (final r in state) if (r.id == id) voided else r];
    } catch (_) {}
  }
}

final contributionReceiptsProvider =
    NotifierProvider<ContributionReceiptsNotifier, List<ContributionReceipt>>(ContributionReceiptsNotifier.new);

