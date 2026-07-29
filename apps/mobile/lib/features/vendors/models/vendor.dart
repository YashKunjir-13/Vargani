import 'package:flutter/foundation.dart';

enum VendorStatus { active, inactive }

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
    required this.status,
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
  final VendorStatus status;
  final DateTime createdAt;
  // These are UI-facing aggregates derived from the mock repository and are
  // intentionally kept on the model for the frontend-only experience.
  final int contractAmountPaise;
  final int paidAmountPaise;
  final int outstandingAmountPaise;
  final VendorContractStatus contractStatus;
  final String? category;

  Vendor copyWith({
    String? id,
    String? name,
    String? contactPerson,
    String? mobile,
    String? email,
    String? address,
    VendorStatus? status,
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
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      contractAmountPaise: contractAmountPaise ?? this.contractAmountPaise,
      paidAmountPaise: paidAmountPaise ?? this.paidAmountPaise,
      outstandingAmountPaise:
          outstandingAmountPaise ?? this.outstandingAmountPaise,
      contractStatus: contractStatus ?? this.contractStatus,
      category: category ?? this.category,
    );
  }
}
