import 'package:flutter/material.dart';

class TransactionItem {
  const TransactionItem({
    required this.id,
    required this.receiptNumber,
    required this.donorName,
    required this.amountPaise,
    required this.paymentMethod,
    required this.date,
    required this.status,
    this.mandalName,
  });

  final String id;
  final String receiptNumber;
  final String donorName;
  final int amountPaise;
  final String paymentMethod;
  final DateTime date;
  final String status;
  final String? mandalName;

  double get amountRupees => amountPaise / 100.0;
}

class MandalModuleItem {
  const MandalModuleItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.badgeCount,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final int? badgeCount;
}

class TopDonorItem {
  const TopDonorItem({
    required this.rank,
    required this.name,
    required this.amountPaise,
  });

  final int rank;
  final String name;
  final int amountPaise;

  double get amountRupees => amountPaise / 100.0;
}

class PendingPaymentItem {
  const PendingPaymentItem({
    required this.id,
    required this.vendorName,
    required this.description,
    required this.amountPaise,
    required this.dueDate,
  });

  final String id;
  final String vendorName;
  final String description;
  final int amountPaise;
  final DateTime dueDate;

  double get amountRupees => amountPaise / 100.0;
}

class BudgetItem {
  const BudgetItem({
    required this.category,
    required this.allocatedPaise,
    required this.spentPaise,
  });

  final String category;
  final int allocatedPaise;
  final int spentPaise;

  double get spentPercentage => (spentPaise / allocatedPaise * 100).clamp(0, 100);
}

class MandalDashboardData {
  const MandalDashboardData({
    required this.mandalName,
    required this.festivalYear,
    required this.currentBalancePaise,
    required this.todaysCollectionPaise,
    required this.totalCollectionPaise,
    required this.totalExpensesPaise,
    required this.pendingBillsCount,
    required this.pendingBillsAmountPaise,
    required this.pendingReceiptsCount,
    required this.activeVolunteersCount,
    required this.totalDonorsCount,
    required this.upcomingEventsCount,
    required this.transactions,
    required this.modules,
    required this.topDonors,
    required this.pendingPayments,
    required this.budgets,
  });

  final String mandalName;
  final String festivalYear;
  final int currentBalancePaise;
  final int todaysCollectionPaise;
  final int totalCollectionPaise;
  final int totalExpensesPaise;
  final int pendingBillsCount;
  final int pendingBillsAmountPaise;
  final int pendingReceiptsCount;
  final int activeVolunteersCount;
  final int totalDonorsCount;
  final int upcomingEventsCount;
  final List<TransactionItem> transactions;
  final List<MandalModuleItem> modules;
  final List<TopDonorItem> topDonors;
  final List<PendingPaymentItem> pendingPayments;
  final List<BudgetItem> budgets;
}

class DonorDashboardData {
  const DonorDashboardData({
    required this.donorName,
    required this.mobile,
    required this.email,
    required this.totalDonationsPaise,
    required this.thisYearDonationsPaise,
    required this.lastDonationAmountPaise,
    required this.lastDonationDate,
    required this.favoriteMandalName,
    required this.digitalReceiptsCount,
    required this.recentDonations,
    required this.yearlyBreakdown,
  });

  final String donorName;
  final String mobile;
  final String email;
  final int totalDonationsPaise;
  final int thisYearDonationsPaise;
  final int lastDonationAmountPaise;
  final DateTime lastDonationDate;
  final String favoriteMandalName;
  final int digitalReceiptsCount;
  final List<TransactionItem> recentDonations;
  final Map<int, int> yearlyBreakdown;
}
