import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../rbac/presentation/providers/mock_rbac_provider.dart';
import '../../models/analytics_models.dart';
import '../../data/repositories/analytics_repository.dart';
import '../../data/repositories/mock_analytics_repository.dart';

final mockAnalyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return MockAnalyticsRepository();
});

class AnalyticsState {
  final bool isLoading;
  final bool isUnauthorized;
  final String? error;
  final AnalyticalDashboardData? data;
  final DateRangeFilter filter;
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  const AnalyticsState({
    this.isLoading = true,
    this.isUnauthorized = false,
    this.error,
    this.data,
    this.filter = DateRangeFilter.entireFestival,
    this.customStartDate,
    this.customEndDate,
  });

  AnalyticsState copyWith({
    bool? isLoading,
    bool? isUnauthorized,
    String? error,
    AnalyticalDashboardData? data,
    DateRangeFilter? filter,
    DateTime? customStartDate,
    DateTime? customEndDate,
  }) {
    return AnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      isUnauthorized: isUnauthorized ?? this.isUnauthorized,
      error: error ?? this.error,
      data: data ?? this.data,
      filter: filter ?? this.filter,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
    );
  }
}

class AnalyticsNotifier extends Notifier<AnalyticsState> {
  @override
  AnalyticsState build() {
    // Initial fetch
    Future.microtask(() => _fetchData());
    return const AnalyticsState(isLoading: true);
  }

  Future<void> _fetchData() async {
    state = state.copyWith(isLoading: true, error: null);

    final rbacState = ref.read(mockRbacProvider);
    if (!rbacState.hasPermission('analytics.view')) {
      state = state.copyWith(isLoading: false, isUnauthorized: true);
      return;
    }

    DateTime? startDate;
    DateTime? endDate;

    final now = DateTime.now();

    switch (state.filter) {
      case DateRangeFilter.entireFestival:
        startDate = null;
        endDate = null;
        break;
      case DateRangeFilter.today:
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day);
        break;
      case DateRangeFilter.thisWeek:
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        endDate = DateTime(now.year, now.month, now.day);
        break;
      case DateRangeFilter.thisMonth:
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month, now.day);
        break;
      case DateRangeFilter.custom:
        startDate = state.customStartDate;
        endDate = state.customEndDate;
        break;
    }

    try {
      final repo = ref.read(mockAnalyticsRepositoryProvider);
      final data =
          await repo.getDashboardData(startDate: startDate, endDate: endDate);
      state =
          state.copyWith(isLoading: false, data: data, isUnauthorized: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setFilter(DateRangeFilter filter,
      {DateTime? customStart, DateTime? customEnd}) {
    state = state.copyWith(
      filter: filter,
      customStartDate: customStart ?? state.customStartDate,
      customEndDate: customEnd ?? state.customEndDate,
    );
    _fetchData();
  }

  void refresh() {
    _fetchData();
  }
}

final analyticsProvider = NotifierProvider<AnalyticsNotifier, AnalyticsState>(
  AnalyticsNotifier.new,
);
