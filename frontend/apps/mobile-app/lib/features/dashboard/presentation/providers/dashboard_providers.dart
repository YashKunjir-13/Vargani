import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pauti_pustak_mobile/core/session/session_controller.dart';
import 'package:pauti_pustak_mobile/features/dashboard/data/models/dashboard_models.dart';

class DashboardTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) => state = index;
}

final dashboardTabProvider =
    NotifierProvider<DashboardTabNotifier, int>(DashboardTabNotifier.new);

const _standardModules = [
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

class MandalDashboardNotifier extends Notifier<MandalDashboardData> {
  @override
  MandalDashboardData build() {
    final session = ref.watch(sessionControllerProvider);
    final orgName = session.user?.organization?.name ?? 'Shree Siddhivinayak Ganpati Mandal';

    Future.microtask(() => fetchDashboardData());

    return MandalDashboardData(
      mandalName: orgName,
      festivalYear: session.user?.organization?.code ?? '',
      currentBalancePaise: 0,
      todaysCollectionPaise: 0,
      totalCollectionPaise: 0,
      totalExpensesPaise: 0,
      pendingBillsCount: 0,
      pendingBillsAmountPaise: 0,
      pendingReceiptsCount: 0,
      activeVolunteersCount: 0,
      totalDonorsCount: 0,
      upcomingEventsCount: 0,
      transactions: const [],
      modules: _standardModules,
      topDonors: const [],
      pendingPayments: const [],
      budgets: const [],
    );
  }

  Future<void> fetchDashboardData() async {
    final session = ref.read(sessionControllerProvider);
    final orgName = session.user?.organization?.name ?? state.mandalName;

    try {
      final dio = ref.read(dioProvider);

      // 1. Fetch Executive Dashboard KPIs from NestJS backend
      final execResp = await dio.get<Map<String, dynamic>>('/dashboards/executive');
      final execData = execResp.data?['data'] as Map<String, dynamic>? ?? {};

      final totalCollections = int.tryParse(execData['totalCollectionsPaise']?.toString() ?? '0') ?? 0;
      final paidExpenses = int.tryParse(execData['paidExpensesPaise']?.toString() ?? '0') ?? 0;
      final balance = int.tryParse(execData['netLiquidityBalancePaise']?.toString() ?? '0') ?? 0;
      final activeEvents = (execData['activeEventsCount'] as num?)?.toInt() ?? 0;
      final activeVolunteers = (execData['activeVolunteersCount'] as num?)?.toInt() ?? 0;
      final collectionsCount = (execData['totalCollectionsCount'] as num?)?.toInt() ?? 0;

      // 2. Fetch Recent Transactions from NestJS Payments API
      List<TransactionItem> realTransactions = [];
      try {
        final payResp = await dio.get<Map<String, dynamic>>('/payments');
        final payList = payResp.data?['data'] as List<dynamic>? ?? (payResp.data is List ? payResp.data as List : []);
        realTransactions = payList.map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          final rawAmount = (map['amountPaise'] as num?)?.toInt() ?? ((map['amount'] as num?)?.toDouble() ?? 0.0 * 100).round();
          final dtStr = map['paymentDateTime'] as String? ?? map['createdAt'] as String?;
          final dateVal = dtStr != null ? DateTime.tryParse(dtStr) ?? DateTime.now() : DateTime.now();
          return TransactionItem(
            id: map['id']?.toString() ?? '',
            receiptNumber: map['receiptNumber']?.toString() ?? 'RCT-${map['id']}',
            donorName: map['donorNameSnapshot']?.toString() ?? map['donorName']?.toString() ?? 'Donor',
            amountPaise: rawAmount,
            paymentMethod: map['paymentMethod']?.toString() ?? map['channel']?.toString() ?? 'Cash',
            date: dateVal,
            status: map['status']?.toString() ?? 'Confirmed',
          );
        }).toList();
      } catch (_) {
        // Fallback to empty transaction list if payments API fails
      }

      state = state.copyWith(
        mandalName: orgName,
        totalCollectionPaise: totalCollections,
        totalExpensesPaise: paidExpenses,
        currentBalancePaise: balance,
        upcomingEventsCount: activeEvents,
        activeVolunteersCount: activeVolunteers,
        totalDonorsCount: collectionsCount,
        transactions: realTransactions,
      );
    } catch (_) {
      state = state.copyWith(mandalName: orgName);
    }
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
      totalDonorsCount: state.totalDonorsCount + 1,
    );
  }
}

final mandalDashboardProvider = NotifierProvider<MandalDashboardNotifier, MandalDashboardData>(MandalDashboardNotifier.new);

class DonorDashboardNotifier extends Notifier<DonorDashboardData> {
  @override
  DonorDashboardData build() {
    final session = ref.watch(sessionControllerProvider);
    final user = session.user;

    Future.microtask(() => fetchDashboard());

    return DonorDashboardData(
      donorName: user?.displayName ?? 'Authenticated Donor',
      mobile: user?.primaryMobile ?? '',
      email: user?.primaryEmail ?? '',
      totalDonationsPaise: 0,
      thisYearDonationsPaise: 0,
      lastDonationAmountPaise: 0,
      lastDonationDate: DateTime.now(),
      favoriteMandalName: '',
      digitalReceiptsCount: 0,
      recentDonations: const [],
      yearlyBreakdown: const {},
    );
  }

  Future<void> fetchDashboard() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/donor/dashboard');

      final dynamic resData = response.data;
      Map<String, dynamic> dataMap = {};
      if (resData is Map<String, dynamic> && resData.containsKey('data')) {
        dataMap = resData['data'] as Map<String, dynamic>;
      } else if (resData is Map<String, dynamic>) {
        dataMap = resData;
      }

      final ytdTotal = int.tryParse(dataMap['ytdTotalContributedPaise']?.toString() ?? '0') ?? 0;
      final receipts = dataMap['recentReceipts'] as List? ?? [];

      List<TransactionItem> recentList = [];
      int lastAmount = 0;
      DateTime lastDate = DateTime.now();

      for (var r in receipts) {
        if (r is Map<String, dynamic>) {
          final amt = int.tryParse(r['amountPaise']?.toString() ?? '0') ?? 0;
          if (lastAmount == 0 && amt > 0) {
            lastAmount = amt;
            if (r['collectedAt'] != null) {
              lastDate = DateTime.tryParse(r['collectedAt'].toString()) ?? DateTime.now();
            }
          }
          recentList.add(
            TransactionItem(
              id: r['id']?.toString() ?? '',
              receiptNumber: r['receiptNumber']?.toString() ?? 'RCPT-${r['id']?.toString().substring(0, 8)}',
              donorName: state.donorName,
              mandalName: r['organizationName']?.toString() ?? 'Mandal Trust',
              amountPaise: amt,
              paymentMethod: r['mode']?.toString() ?? 'UPI',
              date: r['collectedAt'] != null ? (DateTime.tryParse(r['collectedAt'].toString()) ?? DateTime.now()) : DateTime.now(),
              status: 'Confirmed',
            ),
          );
        }
      }

      state = state.copyWith(
        totalDonationsPaise: ytdTotal,
        thisYearDonationsPaise: ytdTotal,
        lastDonationAmountPaise: lastAmount > 0 ? lastAmount : state.lastDonationAmountPaise,
        lastDonationDate: lastDate,
        digitalReceiptsCount: receipts.length,
        recentDonations: recentList.isNotEmpty ? recentList : state.recentDonations,
      );
    } catch (_) {
      // Keep existing state if offline
    }
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

    // Refresh from backend to ensure PostgreSQL source of truth
    fetchDashboard();
  }
}

final donorDashboardProvider = NotifierProvider<DonorDashboardNotifier, DonorDashboardData>(DonorDashboardNotifier.new);
