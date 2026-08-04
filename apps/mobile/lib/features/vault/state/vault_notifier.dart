import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/vault_models.dart';

final vaultProvider = NotifierProvider<VaultNotifier, List<VaultDepositRecord>>(
  VaultNotifier.new,
);

class VaultNotifier extends Notifier<List<VaultDepositRecord>> {
  @override
  List<VaultDepositRecord> build() {
    return [
      VaultDepositRecord(
        id: 'VLT-2025-001',
        date: DateTime(2026, 7, 28, 20, 00),
        sourceLabel: 'Main Temple Daan Peti #1',
        denominations: const CashDenominationCount(
          count500: 420,
          count200: 350,
          count100: 800,
          count50: 400,
          count20: 500,
          count10: 1000,
          coinsAmount: 12500,
        ),
        status: VaultStatus.inVault,
        treasurerSigned: true,
        presidentSigned: true,
        notes: 'Evening counting session completed post Mahaarati.',
      ),
      VaultDepositRecord(
        id: 'VLT-2025-002',
        date: DateTime(2026, 7, 27, 21, 30),
        sourceLabel: 'Vip Mandap Counter Cash Box',
        denominations: const CashDenominationCount(
          count500: 250,
          count200: 180,
          count100: 500,
          coinsAmount: 8500,
        ),
        status: VaultStatus.inTransit,
        treasurerSigned: true,
        presidentSigned: false,
        notes: 'Handed over to Cash Van arm guard for SBI main branch deposit.',
      ),
      VaultDepositRecord(
        id: 'VLT-2025-003',
        date: DateTime(2026, 7, 25, 19, 00),
        sourceLabel: 'Day 1 Opening Collection Vault',
        denominations: const CashDenominationCount(
          count500: 600,
          count200: 400,
          count100: 1200,
          coinsAmount: 25000,
        ),
        status: VaultStatus.deposited,
        treasurerSigned: true,
        presidentSigned: true,
        bankReferenceNumber: 'SBI-TXN-9842104921',
        notes: 'Credited to Mandal Current A/C #30491829104.',
      ),
    ];
  }

  void addRecord(VaultDepositRecord record) {
    state = [record, ...state];
  }

  void signOffAsPresident(String recordId) {
    state = state.map((r) {
      if (r.id == recordId) {
        return r.copyWith(presidentSigned: true);
      }
      return r;
    }).toList();
  }

  void updateStatus(String recordId, VaultStatus newStatus, {String? bankReferenceNumber}) {
    state = state.map((r) {
      if (r.id == recordId) {
        return r.copyWith(
          status: newStatus,
          bankReferenceNumber: bankReferenceNumber ?? r.bankReferenceNumber,
        );
      }
      return r;
    }).toList();
  }
}
