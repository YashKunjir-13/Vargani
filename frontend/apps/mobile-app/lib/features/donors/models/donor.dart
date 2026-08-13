import 'package:flutter/foundation.dart';

enum DonorProfileStatus { unclaimed, active, deactivated, merged }

@immutable
class Donor {
  const Donor({
    required this.id,
    required this.fullName,
    this.mobile,
    this.email,
    required this.status,
    this.claimedAt,
    required this.createdAt,
    required this.totalContributionsCount,
    required this.totalConfirmedAmountPaise,
  });

  final String id;
  final String fullName;
  final String? mobile;
  final String? email;
  final DonorProfileStatus status;
  final DateTime? claimedAt;
  final DateTime createdAt;
  final int totalContributionsCount;
  final int totalConfirmedAmountPaise;

  Donor copyWith({
    String? id,
    String? fullName,
    String? mobile,
    String? email,
    DonorProfileStatus? status,
    DateTime? claimedAt,
    DateTime? createdAt,
    int? totalContributionsCount,
    int? totalConfirmedAmountPaise,
  }) {
    return Donor(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      status: status ?? this.status,
      claimedAt: claimedAt ?? this.claimedAt,
      createdAt: createdAt ?? this.createdAt,
      totalContributionsCount:
          totalContributionsCount ?? this.totalContributionsCount,
      totalConfirmedAmountPaise:
          totalConfirmedAmountPaise ?? this.totalConfirmedAmountPaise,
    );
  }
}
