import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ledger_models.dart';

final bankAccountProvider = Provider<BankAccountData>((ref) {
  return const BankAccountData(
    accountId: 'ACC-SBI-001',
    bankName: 'State Bank of India',
    accountNumber: '•••• •••• 9104',
    ifscCode: 'SBIN0001824',
    currentBalance: 367500.0,
    pendingVaultDeposits: 42800.0,
  );
});

final bankDepositsProvider = NotifierProvider<BankDepositsNotifier, List<BankDepositEntry>>(
  BankDepositsNotifier.new,
);

class BankDepositsNotifier extends Notifier<List<BankDepositEntry>> {
  @override
  List<BankDepositEntry> build() {
    return [
      BankDepositEntry(
        id: 'DEP-2025-001',
        date: DateTime(2026, 7, 26, 14, 30),
        amount: 150000.0,
        bankName: 'State Bank of India',
        referenceNumber: 'SBI-TXN-9842104921',
        depositedBy: 'Priya Deshmukh (Treasurer)',
        status: 'Reconciled',
      ),
      BankDepositEntry(
        id: 'DEP-2025-002',
        date: DateTime(2026, 7, 22, 11, 00),
        amount: 85000.0,
        bankName: 'State Bank of India',
        referenceNumber: 'SBI-TXN-8821039182',
        depositedBy: 'Amit Kulkarni (President)',
        status: 'Reconciled',
      ),
    ];
  }

  void addDeposit(BankDepositEntry deposit) {
    state = [deposit, ...state];
  }
}
