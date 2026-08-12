import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pauti_pustak_mobile/core/session/session_controller.dart';

import '../data/receipts_remote_datasource.dart';
import '../models/receipt.dart';

final receiptsRemoteDataSourceProvider = Provider<ReceiptsRemoteDataSource>((ref) {
  return ReceiptsRemoteDataSource(ref.watch(dioProvider));
});

class ReceiptsNotifier extends Notifier<AsyncValue<List<Receipt>>> {
  @override
  AsyncValue<List<Receipt>> build() {
    loadReceipts();
    return const AsyncValue.data([]);
  }

  Future<void> loadReceipts() async {
    try {
      final dataSource = ref.read(receiptsRemoteDataSourceProvider);
      final receipts = await dataSource.fetchReceipts();
      if (!ref.mounted) return;
      state = AsyncValue.data(receipts);
    } catch (err, stack) {
      if (!ref.mounted) return;
      if (state.value == null || state.value!.isEmpty) {
        state = AsyncValue.error(err, stack);
      }
    }
  }

  Future<void> loadMyHistory() async {
    try {
      final dataSource = ref.read(receiptsRemoteDataSourceProvider);
      final receipts = await dataSource.fetchMyHistory();
      if (!ref.mounted) return;
      state = AsyncValue.data(receipts);
    } catch (err, stack) {
      if (!ref.mounted) return;
      if (state.value == null || state.value!.isEmpty) {
        state = AsyncValue.error(err, stack);
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
      final currentList = state.value ?? [];
      final index = currentList.indexWhere((r) => r.id == id);
      if (index != -1) {
        final updatedList = List<Receipt>.from(currentList);
        updatedList[index] = updatedList[index].copyWith(whatsappDeliveryStatus: WhatsappDeliveryStatus.sent);
        state = AsyncValue.data(updatedList);
      }
      return true;
    }
  }
}

final receiptsProvider = NotifierProvider<ReceiptsNotifier, AsyncValue<List<Receipt>>>(
  ReceiptsNotifier.new,
);
