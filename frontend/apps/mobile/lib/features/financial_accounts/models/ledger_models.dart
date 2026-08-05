import 'package:flutter/foundation.dart';

@immutable
class BankAccountData {
  final String accountId;
  final String bankName;
  final String accountNumber;
  final String ifscCode;
  final double currentBalance;
  final double pendingVaultDeposits;

  const BankAccountData({
    required this.accountId,
    required this.bankName,
    required this.accountNumber,
    required this.ifscCode,
    required this.currentBalance,
    required this.pendingVaultDeposits,
  });
}

@immutable
class BankDepositEntry {
  final String id;
  final DateTime date;
  final double amount;
  final String bankName;
  final String referenceNumber;
  final String depositedBy;
  final String status;

  const BankDepositEntry({
    required this.id,
    required this.date,
    required this.amount,
    required this.bankName,
    required this.referenceNumber,
    required this.depositedBy,
    required this.status,
  });
}
