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
  static const defaultModules = [
    MandalModuleItem(
      id: 'contributions',
      title: 'Contribution Management',
      subtitle: 'Track & record vargani',
      icon: Icons.monetization_on_outlined,
    ),
    MandalModuleItem(
      id: 'collection',
      title: 'Donation Collection',
      subtitle: 'Spot collection & QR code',
      icon: Icons.handshake_outlined,
    ),
    MandalModuleItem(
      id: 'receipts',
      title: 'Receipt Generation',
      subtitle: 'Instant PDF & SMS receipts',
      icon: Icons.receipt_long_outlined,
    ),
    MandalModuleItem(
      id: 'budget',
      title: 'Budget Management',
      subtitle: 'Allocate & monitor budgets',
      icon: Icons.account_balance_outlined,
    ),
    MandalModuleItem(
      id: 'bills',
      title: 'Bill Management',
      subtitle: 'Vendor invoices & approvals',
      icon: Icons.description_outlined,
    ),
    MandalModuleItem(
      id: 'kunda',
      title: 'Donation Box (Kunda)',
      subtitle: 'Cash counting & log',
      icon: Icons.inbox_outlined,
    ),
    MandalModuleItem(
      id: 'all_records',
      title: 'All Records',
      subtitle: 'Browse all category records',
      icon: Icons.folder_open_outlined,
    ),
    MandalModuleItem(
      id: 'members',
      title: 'Member Management',
      subtitle: 'Trustees & committee',
      icon: Icons.badge_outlined,
    ),
    MandalModuleItem(
      id: 'reports',
      title: 'Reports',
      subtitle: 'P&L, Audit & Tax reports',
      icon: Icons.assessment_outlined,
    ),
    MandalModuleItem(
      id: 'audit',
      title: 'Audit Log',
      subtitle: 'Compliance & immutable logs',
      icon: Icons.verified_user_outlined,
    ),
    MandalModuleItem(
      id: 'analytics',
      title: 'Analytics',
      subtitle: 'Real-time revenue insights',
      icon: Icons.analytics_outlined,
    ),
  ];

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
    this.modules = defaultModules,
    this.topDonors = const [],
    this.pendingPayments = const [],
    this.budgets = const [],
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

  MandalDashboardData copyWith({
    String? mandalName,
    String? festivalYear,
    int? currentBalancePaise,
    int? todaysCollectionPaise,
    int? totalCollectionPaise,
    int? totalExpensesPaise,
    int? pendingBillsCount,
    int? pendingBillsAmountPaise,
    int? pendingReceiptsCount,
    int? activeVolunteersCount,
    int? totalDonorsCount,
    int? upcomingEventsCount,
    List<TransactionItem>? transactions,
    List<MandalModuleItem>? modules,
    List<TopDonorItem>? topDonors,
    List<PendingPaymentItem>? pendingPayments,
    List<BudgetItem>? budgets,
  }) {
    return MandalDashboardData(
      mandalName: mandalName ?? this.mandalName,
      festivalYear: festivalYear ?? this.festivalYear,
      currentBalancePaise: currentBalancePaise ?? this.currentBalancePaise,
      todaysCollectionPaise: todaysCollectionPaise ?? this.todaysCollectionPaise,
      totalCollectionPaise: totalCollectionPaise ?? this.totalCollectionPaise,
      totalExpensesPaise: totalExpensesPaise ?? this.totalExpensesPaise,
      pendingBillsCount: pendingBillsCount ?? this.pendingBillsCount,
      pendingBillsAmountPaise: pendingBillsAmountPaise ?? this.pendingBillsAmountPaise,
      pendingReceiptsCount: pendingReceiptsCount ?? this.pendingReceiptsCount,
      activeVolunteersCount: activeVolunteersCount ?? this.activeVolunteersCount,
      totalDonorsCount: totalDonorsCount ?? this.totalDonorsCount,
      upcomingEventsCount: upcomingEventsCount ?? this.upcomingEventsCount,
      transactions: transactions ?? this.transactions,
      modules: modules ?? this.modules,
      topDonors: topDonors ?? this.topDonors,
      pendingPayments: pendingPayments ?? this.pendingPayments,
      budgets: budgets ?? this.budgets,
    );
  }
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

  DonorDashboardData copyWith({
    String? donorName,
    String? mobile,
    String? email,
    int? totalDonationsPaise,
    int? thisYearDonationsPaise,
    int? lastDonationAmountPaise,
    DateTime? lastDonationDate,
    String? favoriteMandalName,
    int? digitalReceiptsCount,
    List<TransactionItem>? recentDonations,
    Map<int, int>? yearlyBreakdown,
  }) {
    return DonorDashboardData(
      donorName: donorName ?? this.donorName,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      totalDonationsPaise: totalDonationsPaise ?? this.totalDonationsPaise,
      thisYearDonationsPaise: thisYearDonationsPaise ?? this.thisYearDonationsPaise,
      lastDonationAmountPaise: lastDonationAmountPaise ?? this.lastDonationAmountPaise,
      lastDonationDate: lastDonationDate ?? this.lastDonationDate,
      favoriteMandalName: favoriteMandalName ?? this.favoriteMandalName,
      digitalReceiptsCount: digitalReceiptsCount ?? this.digitalReceiptsCount,
      recentDonations: recentDonations ?? this.recentDonations,
      yearlyBreakdown: yearlyBreakdown ?? this.yearlyBreakdown,
    );
  }
}
