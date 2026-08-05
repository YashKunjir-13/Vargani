import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pauti_pustak_mobile/core/session/session_controller.dart';

import '../data/receipts_remote_datasource.dart';
import '../models/receipt.dart';

import '../data/receipts_mock_data.dart';

final receiptsRemoteDataSourceProvider = Provider<ReceiptsRemoteDataSource>((ref) {
  return ReceiptsRemoteDataSource(ref.watch(dioProvider));
});

class ReceiptsNotifier extends Notifier<AsyncValue<List<Receipt>>> {
  @override
  AsyncValue<List<Receipt>> build() {
    loadReceipts();
    return AsyncValue.data(buildMockReceipts());
  }

  Future<void> loadReceipts() async {
    try {
      final dataSource = ref.read(receiptsRemoteDataSourceProvider);
      final receipts = await dataSource.fetchReceipts();
      if (receipts.isNotEmpty) {
        state = AsyncValue.data(receipts);
      }
    } catch (_) {
      if (state.value == null || state.value!.isEmpty) {
        state = AsyncValue.data(buildMockReceipts());
      }
    }
  }

  Future<void> loadMyHistory() async {
    try {
      final dataSource = ref.read(receiptsRemoteDataSourceProvider);
      final receipts = await dataSource.fetchMyHistory();
      if (receipts.isNotEmpty) {
        state = AsyncValue.data(receipts);
      }
    } catch (_) {
      if (state.value == null || state.value!.isEmpty) {
        state = AsyncValue.data(buildMockReceipts());
      }
    }
  }

  Future<bool> resendWhatsapp(String id) async {
    try {
      final dataSource = ref.read(receiptsRemoteDataSourceProvider);
      await dataSource.resendWhatsapp(id);
      await loadReceipts();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final receiptsProvider = NotifierProvider<ReceiptsNotifier, AsyncValue<List<Receipt>>>(
  ReceiptsNotifier.new,
);
