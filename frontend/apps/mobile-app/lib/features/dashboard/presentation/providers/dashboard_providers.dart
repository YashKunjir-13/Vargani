import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pauti_pustak_mobile/features/dashboard/data/models/dashboard_models.dart';

class DashboardTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) => state = index;
}

final dashboardTabProvider =
    NotifierProvider<DashboardTabNotifier, int>(DashboardTabNotifier.new);

class MandalDashboardNotifier extends Notifier<MandalDashboardData> {
  @override
  MandalDashboardData build() {
    return MandalDashboardData(
      mandalName: 'Shree Siddhivinayak Ganpati Mandal',
      festivalYear: 'Ganpati Utsav 2025',
      currentBalancePaise: 36750000,
      todaysCollectionPaise: 4280000,
      totalCollectionPaise: 48230000,
      totalExpensesPaise: 11480000,
      pendingBillsCount: 5,
      pendingBillsAmountPaise: 1840000,
      pendingReceiptsCount: 3,
      activeVolunteersCount: 24,
      totalDonorsCount: 342,
      upcomingEventsCount: 1,
      transactions: [
        TransactionItem(
          id: '1',
          receiptNumber: 'RCT-2025-089',
          donorName: 'Rajesh Ramniklal Sharma',
          amountPaise: 500100,
          paymentMethod: 'UPI (GPay)',
          date: DateTime(2026, 7, 28, 10, 30),
          status: 'Confirmed',
        ),
        TransactionItem(
          id: '2',
          receiptNumber: 'RCT-2025-088',
          donorName: 'Vijay Vasantrao Kulkarni',
          amountPaise: 1100000,
          paymentMethod: 'Cash',
          date: DateTime(2026, 7, 28, 09, 15),
          status: 'Confirmed',
        ),
        TransactionItem(
          id: '3',
          receiptNumber: 'RCT-2025-087',
          donorName: 'Sunita Prabhakar Deshmukh',
          amountPaise: 250000,
          paymentMethod: 'Net Banking',
          date: DateTime(2026, 7, 27, 18, 45),
          status: 'Verified',
        ),
        TransactionItem(
          id: '4',
          receiptNumber: 'RCT-2025-086',
          donorName: 'Anil Dattatray Shinde',
          amountPaise: 510000,
          paymentMethod: 'UPI (PhonePe)',
          date: DateTime(2026, 7, 27, 14, 20),
          status: 'Confirmed',
        ),
        TransactionItem(
          id: '5',
          receiptNumber: 'RCT-2025-085',
          donorName: 'Meena Suresh Joshi',
          amountPaise: 100100,
          paymentMethod: 'Cash',
          date: DateTime(2026, 7, 26, 11, 10),
          status: 'Confirmed',
        ),
      ],
      modules: const [
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
          badgeCount: 5,
        ),
        MandalModuleItem(
          id: 'vendor_payments',
          title: 'Vendor Payments',
          subtitle: 'Approve & record payouts',
          icon: Icons.payments_outlined,
        ),
        MandalModuleItem(
          id: 'kunda',
          title: 'Donation Box (Kunda)',
          subtitle: 'Cash counting & log',
          icon: Icons.inbox_outlined,
        ),
        MandalModuleItem(
          id: 'sponsors',
          title: 'Sponsors',
          subtitle: 'Banners & main sponsors',
          icon: Icons.card_membership_outlined,
        ),
        MandalModuleItem(
          id: 'all_records',
          title: 'All Records',
          subtitle: 'Browse all category records',
          icon: Icons.folder_open_outlined,
        ),
        MandalModuleItem(
          id: 'advertisements',
          title: 'Advertisements',
          subtitle: 'Souvenir & ad slots',
          icon: Icons.campaign_outlined,
        ),
        MandalModuleItem(
          id: 'volunteers',
          title: 'Volunteers',
          subtitle: 'Duty roster & assignment',
          icon: Icons.groups_outlined,
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
      ],
      topDonors: const [
        TopDonorItem(rank: 1, name: 'Ramesh Shivaji Patil', amountPaise: 2500000),
        TopDonorItem(rank: 2, name: 'Vijay Vasantrao Kulkarni', amountPaise: 2100000),
        TopDonorItem(rank: 3, name: 'Mahesh Dattatray Kulkarni', amountPaise: 1500000),
        TopDonorItem(rank: 4, name: 'Sunita Prabhakar Deshmukh', amountPaise: 1100000),
        TopDonorItem(rank: 5, name: 'Rajesh Ramniklal Sharma', amountPaise: 1000000),
      ],
      pendingPayments: [
        PendingPaymentItem(
          id: 'p1',
          vendorName: 'Sai Decorators & Tent House',
          description: 'Main Mandap Stage Setup',
          amountPaise: 1250000,
          dueDate: DateTime(2026, 8, 5),
        ),
        PendingPaymentItem(
          id: 'p2',
          vendorName: 'Shree Ganesh Audio Systems',
          description: 'Sound System & Mic Rental',
          amountPaise: 350000,
          dueDate: DateTime(2026, 8, 10),
        ),
        PendingPaymentItem(
          id: 'p3',
          vendorName: 'Mahalaxmi Caterers',
          description: 'Prasad & Mahaprasad Preparation',
          amountPaise: 240000,
          dueDate: DateTime(2026, 8, 12),
        ),
      ],
      budgets: const [
        BudgetItem(category: 'Decoration & Lighting', allocatedPaise: 20000000, spentPaise: 17000000),
        BudgetItem(category: 'Prasad & Catering', allocatedPaise: 15000000, spentPaise: 9000000),
        BudgetItem(category: 'Sound & Orchestra', allocatedPaise: 8000000, spentPaise: 6400000),
        BudgetItem(category: 'Security & CCTV', allocatedPaise: 5000000, spentPaise: 2000000),
      ],
    );
  }

  void addDonation({
    required int amountPaise,
    required String paymentMethod,
    required String donorName,
  }) {
    final now = DateTime.now();
    final newTx = TransactionItem(
      id: 'new_${now.millisecondsSinceEpoch}',
      receiptNumber: 'RCT-${now.year}-${now.millisecondsSinceEpoch.toString().substring(9)}',
      donorName: donorName,
      amountPaise: amountPaise,
      paymentMethod: paymentMethod,
      date: now,
      status: 'Confirmed',
    );

    final newTransactions = [newTx, ...state.transactions];

    state = state.copyWith(
      transactions: newTransactions,
      todaysCollectionPaise: state.todaysCollectionPaise + amountPaise,
      totalCollectionPaise: state.totalCollectionPaise + amountPaise,
      currentBalancePaise: state.currentBalancePaise + amountPaise,
    );
  }
}

final mandalDashboardProvider = NotifierProvider<MandalDashboardNotifier, MandalDashboardData>(MandalDashboardNotifier.new);

class DonorDashboardNotifier extends Notifier<DonorDashboardData> {
  @override
  DonorDashboardData build() {
    return DonorDashboardData(
      donorName: 'Ramesh Shivaji Patil',
      mobile: '9876543210',
      email: 'ramesh@email.com',
      totalDonationsPaise: 5100000,
      thisYearDonationsPaise: 1500000,
      lastDonationAmountPaise: 500100,
      lastDonationDate: DateTime(2026, 7, 20),
      favoriteMandalName: 'Shree Siddhivinayak Ganpati Mandal',
      digitalReceiptsCount: 8,
      recentDonations: [
        TransactionItem(
          id: 'd1',
          receiptNumber: 'RCT-2025-089',
          donorName: 'Ramesh Shivaji Patil',
          mandalName: 'Shree Siddhivinayak Ganpati Mandal',
          amountPaise: 500100,
          paymentMethod: 'UPI (PhonePe)',
          date: DateTime(2026, 7, 20),
          status: 'Confirmed',
        ),
        TransactionItem(
          id: 'd2',
          receiptNumber: 'RCT-2025-042',
          donorName: 'Ramesh Shivaji Patil',
          mandalName: 'Shree Siddhivinayak Ganpati Mandal',
          amountPaise: 1000000,
          paymentMethod: 'Net Banking',
          date: DateTime(2026, 6, 15),
          status: 'Confirmed',
        ),
        TransactionItem(
          id: 'd3',
          receiptNumber: 'RCT-2024-192',
          donorName: 'Ramesh Shivaji Patil',
          mandalName: 'Lalbaugcha Raja Sarvajanik Ganeshotsav',
          amountPaise: 2100000,
          paymentMethod: 'UPI (GPay)',
          date: DateTime(2024, 9, 10),
          status: 'Confirmed',
        ),
        TransactionItem(
          id: 'd4',
          receiptNumber: 'RCT-2024-055',
          donorName: 'Ramesh Shivaji Patil',
          mandalName: 'Shree Siddhivinayak Ganpati Mandal',
          amountPaise: 1500000,
          paymentMethod: 'Cheque',
          date: DateTime(2024, 8, 25),
          status: 'Confirmed',
        ),
      ],
      yearlyBreakdown: const {
        2024: 3600000,
        2025: 0,
        2026: 1500000,
      },
    );
  }

  void addDonation({
    required int amountPaise,
    required String paymentMethod,
    required String mandalName,
  }) {
    final now = DateTime.now();
    final newTx = TransactionItem(
      id: 'new_${now.millisecondsSinceEpoch}',
      receiptNumber: 'RCT-${now.year}-${now.millisecondsSinceEpoch.toString().substring(9)}',
      donorName: state.donorName,
      mandalName: mandalName,
      amountPaise: amountPaise,
      paymentMethod: paymentMethod,
      date: now,
      status: 'Confirmed',
    );

    final newRecentDonations = [newTx, ...state.recentDonations];
    
    final currentYear = now.year;
    final newYearlyBreakdown = Map<int, int>.from(state.yearlyBreakdown);
    newYearlyBreakdown[currentYear] = (newYearlyBreakdown[currentYear] ?? 0) + amountPaise;

    state = state.copyWith(
      recentDonations: newRecentDonations,
      totalDonationsPaise: state.totalDonationsPaise + amountPaise,
      thisYearDonationsPaise: state.thisYearDonationsPaise + amountPaise,
      lastDonationAmountPaise: amountPaise,
      lastDonationDate: now,
      digitalReceiptsCount: state.digitalReceiptsCount + 1,
      yearlyBreakdown: newYearlyBreakdown,
    );
  }
}

final donorDashboardProvider = NotifierProvider<DonorDashboardNotifier, DonorDashboardData>(DonorDashboardNotifier.new);
