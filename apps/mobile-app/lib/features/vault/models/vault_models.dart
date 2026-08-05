import 'package:flutter/foundation.dart';

enum VaultStatus {
  inVault,
  inTransit,
  deposited,
}

extension VaultStatusX on VaultStatus {
  String get label {
    switch (this) {
      case VaultStatus.inVault:
        return 'In-Vault';
      case VaultStatus.inTransit:
        return 'In-Transit';
      case VaultStatus.deposited:
        return 'Deposited';
    }
  }
}

@immutable
class CashDenominationCount {
  final int count2000;
  final int count500;
  final int count200;
  final int count100;
  final int count50;
  final int count20;
  final int count10;
  final int coinsAmount;

  const CashDenominationCount({
    this.count2000 = 0,
    this.count500 = 0,
    this.count200 = 0,
    this.count100 = 0,
    this.count50 = 0,
    this.count20 = 0,
    this.count10 = 0,
    this.coinsAmount = 0,
  });

  int get totalAmount {
    return (count2000 * 2000) +
        (count500 * 500) +
        (count200 * 200) +
        (count100 * 100) +
        (count50 * 50) +
        (count20 * 20) +
        (count10 * 10) +
        coinsAmount;
  }

  CashDenominationCount copyWith({
    int? count2000,
    int? count500,
    int? count200,
    int? count100,
    int? count50,
    int? count20,
    int? count10,
    int? coinsAmount,
  }) {
    return CashDenominationCount(
      count2000: count2000 ?? this.count2000,
      count500: count500 ?? this.count500,
      count200: count200 ?? this.count200,
      count100: count100 ?? this.count100,
      count50: count50 ?? this.count50,
      count20: count20 ?? this.count20,
      count10: count10 ?? this.count10,
      coinsAmount: coinsAmount ?? this.coinsAmount,
    );
  }
}

@immutable
class VaultDepositRecord {
  final String id;
  final DateTime date;
  final String sourceLabel;
  final CashDenominationCount denominations;
  final VaultStatus status;
  final bool treasurerSigned;
  final bool presidentSigned;
  final String? bankReferenceNumber;
  final String? notes;

  const VaultDepositRecord({
    required this.id,
    required this.date,
    required this.sourceLabel,
    required this.denominations,
    required this.status,
    required this.treasurerSigned,
    required this.presidentSigned,
    this.bankReferenceNumber,
    this.notes,
  });

  int get totalAmount => denominations.totalAmount;

  VaultDepositRecord copyWith({
    String? id,
    DateTime? date,
    String? sourceLabel,
    CashDenominationCount? denominations,
    VaultStatus? status,
    bool? treasurerSigned,
    bool? presidentSigned,
    String? bankReferenceNumber,
    String? notes,
  }) {
    return VaultDepositRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      sourceLabel: sourceLabel ?? this.sourceLabel,
      denominations: denominations ?? this.denominations,
      status: status ?? this.status,
      treasurerSigned: treasurerSigned ?? this.treasurerSigned,
      presidentSigned: presidentSigned ?? this.presidentSigned,
      bankReferenceNumber: bankReferenceNumber ?? this.bankReferenceNumber,
      notes: notes ?? this.notes,
    );
  }
}
