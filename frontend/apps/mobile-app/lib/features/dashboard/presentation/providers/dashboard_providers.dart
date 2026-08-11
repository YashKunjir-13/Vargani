import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pauti_pustak_mobile/core/session/session_controller.dart';
import 'package:pauti_pustak_mobile/features/dashboard/data/dashboard_remote_datasource.dart';
import 'package:pauti_pustak_mobile/features/dashboard/data/models/dashboard_models.dart';

class DashboardTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) => state = index;
}

final dashboardTabProvider =
    NotifierProvider<DashboardTabNotifier, int>(DashboardTabNotifier.new);

final dashboardRemoteDataSourceProvider =
    Provider<DashboardRemoteDataSource>((ref) {
  return DashboardRemoteDataSource(ref.watch(dioProvider));
});

class MandalDashboardNotifier extends Notifier<MandalDashboardData> {
  @override
  MandalDashboardData build() {
    _fetchLiveDashboard();
    return const MandalDashboardData(
      mandalName: 'Mandal Organization',
      festivalYear: 'Utsav 2026',
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
      transactions: [],
    );
  }

  Future<void> _fetchLiveDashboard() async {
    try {
      final remote = ref.read(dashboardRemoteDataSourceProvider);
      final liveData = await remote.getMandalDashboard();
      state = liveData;
    } catch (_) {
      // Retain state if initial call is offline
    }
  }

  Future<void> refresh() => _fetchLiveDashboard();

  void addDonation({
    required int amountPaise,
    required String paymentMethod,
    required String donorName,
  }) {
    final now = DateTime.now();
    final newTx = TransactionItem(
      id: 'new_${now.millisecondsSinceEpoch}',
      receiptNumber:
          'RCT-${now.year}-${now.millisecondsSinceEpoch.toString().substring(9)}',
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

final mandalDashboardProvider =
    NotifierProvider<MandalDashboardNotifier, MandalDashboardData>(
        MandalDashboardNotifier.new);

class DonorDashboardNotifier extends Notifier<DonorDashboardData> {
  @override
  DonorDashboardData build() {
    return DonorDashboardData(
      donorName: 'Donor Account',
      mobile: '',
      email: '',
      totalDonationsPaise: 0,
      thisYearDonationsPaise: 0,
      lastDonationAmountPaise: 0,
      lastDonationDate: DateTime.now(),
      favoriteMandalName: '',
      digitalReceiptsCount: 0,
      recentDonations: [],
      yearlyBreakdown: const {},
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
      receiptNumber:
          'RCT-${now.year}-${now.millisecondsSinceEpoch.toString().substring(9)}',
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
    newYearlyBreakdown[currentYear] =
        (newYearlyBreakdown[currentYear] ?? 0) + amountPaise;

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

final donorDashboardProvider =
    NotifierProvider<DonorDashboardNotifier, DonorDashboardData>(
        DonorDashboardNotifier.new);
