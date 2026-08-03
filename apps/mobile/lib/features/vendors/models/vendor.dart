import 'package:flutter/foundation.dart';

enum VendorStatus { active, inactive }

extension VendorStatusExtension on VendorStatus {
  String get label {
    return switch (this) {
      VendorStatus.active => 'Active',
      VendorStatus.inactive => 'Inactive',
    };
  }
}

enum VendorContractStatus { active, complete, pending }

@immutable
class Vendor {
  const Vendor({
    required this.id,
    required this.name,
    this.contactPerson,
    this.mobile,
    this.email,
    this.address,
    this.gstin,
    this.pan,
    this.bankAccount,
    this.bankIfsc,
    required this.status,
    this.deactivatedAt,
    this.deactivatedByUserId,
    required this.createdAt,
    required this.contractAmountPaise,
    required this.paidAmountPaise,
    required this.outstandingAmountPaise,
    required this.contractStatus,
    this.category,
  });

  final String id;
  final String name;
  final String? contactPerson;
  final String? mobile;
  final String? email;
  final String? address;
  final String? gstin;
  final String? pan;
  final String? bankAccount;
  final String? bankIfsc;
  final VendorStatus status;
  final DateTime? deactivatedAt;
  final String? deactivatedByUserId;
  final DateTime createdAt;

  // UI-facing aggregates for financial tracking
  final int contractAmountPaise;
  final int paidAmountPaise;
  final int outstandingAmountPaise;
  final VendorContractStatus contractStatus;
  final String? category;

  String get maskedGstin {
    if (gstin == null || gstin!.length < 10) return gstin ?? '—';
    return '${gstin!.substring(0, 5)}****${gstin!.substring(gstin!.length - 3)}';
  }

  String get maskedPan {
    if (pan == null || pan!.length < 8) return pan ?? '—';
    return '${pan!.substring(0, 5)}****${pan!.substring(pan!.length - 1)}';
  }

  String get maskedBankAccount {
    if (bankAccount == null || bankAccount!.length < 4) return bankAccount ?? '—';
    final last4 = bankAccount!.substring(bankAccount!.length - 4);
    return 'XXXX XXXX $last4';
  }

  String get maskedBankIfsc {
    if (bankIfsc == null || bankIfsc!.length < 6) return bankIfsc ?? '—';
    return '${bankIfsc!.substring(0, 4)}****${bankIfsc!.substring(bankIfsc!.length - 2)}';
  }

  Vendor copyWith({
    String? id,
    String? name,
    String? contactPerson,
    String? mobile,
    String? email,
    String? address,
    String? gstin,
    String? pan,
    String? bankAccount,
    String? bankIfsc,
    VendorStatus? status,
    DateTime? deactivatedAt,
    String? deactivatedByUserId,
    DateTime? createdAt,
    int? contractAmountPaise,
    int? paidAmountPaise,
    int? outstandingAmountPaise,
    VendorContractStatus? contractStatus,
    String? category,
  }) {
    return Vendor(
      id: id ?? this.id,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      address: address ?? this.address,
      gstin: gstin ?? this.gstin,
      pan: pan ?? this.pan,
      bankAccount: bankAccount ?? this.bankAccount,
      bankIfsc: bankIfsc ?? this.bankIfsc,
      status: status ?? this.status,
      deactivatedAt: deactivatedAt ?? this.deactivatedAt,
      deactivatedByUserId: deactivatedByUserId ?? this.deactivatedByUserId,
      createdAt: createdAt ?? this.createdAt,
      contractAmountPaise: contractAmountPaise ?? this.contractAmountPaise,
      paidAmountPaise: paidAmountPaise ?? this.paidAmountPaise,
      outstandingAmountPaise: outstandingAmountPaise ?? this.outstandingAmountPaise,
      contractStatus: contractStatus ?? this.contractStatus,
      category: category ?? this.category,
    );
  }
}
