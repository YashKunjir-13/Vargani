import 'package:dio/dio.dart';
import '../../../../core/network/api_error_mapper.dart';
import 'models/dashboard_models.dart';

class DashboardRemoteDataSource {
  DashboardRemoteDataSource(this._dio);

  final Dio _dio;

  Future<MandalDashboardData> getMandalDashboard() async {
    return guardApiCall(() async {
      final response = await _dio.get<Map<String, dynamic>>('/dashboards/executive');
      final data = response.data!['data'] as Map<String, dynamic>;

      final activeVolunteers = (data['activeVolunteersCount'] as num?)?.toInt() ?? 0;
      final activeEvents = (data['activeEventsCount'] as num?)?.toInt() ?? 0;
      
      final totalCollectionsPaise = int.tryParse(data['totalCollectionsPaise']?.toString() ?? '0') ?? 0;
      final paidExpensesPaise = int.tryParse(data['paidExpensesPaise']?.toString() ?? '0') ?? 0;
      final netBalancePaise = int.tryParse(data['netLiquidityBalancePaise']?.toString() ?? '0') ?? 0;
      final todayTotalCollectedPaise = int.tryParse(data['todayTotalCollectedPaise']?.toString() ?? '0') ?? 0;
      final totalDonorsCount = (data['totalDonorsCount'] as num?)?.toInt() ?? 0;

      // Fetch recent transactions if available
      List<TransactionItem> recentTransactions = [];
      try {
        final txResponse = await _dio.get<Map<String, dynamic>>('/contributions', queryParameters: {'limit': 5});
        if (txResponse.data?['data'] is List) {
          final list = txResponse.data!['data'] as List;
          recentTransactions = list.map((item) {
            final m = item as Map<String, dynamic>;
            final amountStr = m['amountPaise']?.toString() ?? '0';
            return TransactionItem(
              id: m['id'] as String? ?? '',
              receiptNumber: m['receiptNumber'] as String? ?? 'RCT-${m['id']?.toString().substring(0, 6)}',
              donorName: m['contributor']?['fullName'] as String? ?? m['donorName'] as String? ?? 'Anonymous Donor',
              amountPaise: int.tryParse(amountStr) ?? 0,
              paymentMethod: m['paymentMode'] as String? ?? m['mode'] as String? ?? 'UPI',
              date: m['createdAt'] != null ? DateTime.parse(m['createdAt'] as String) : DateTime.now(),
              status: m['status'] as String? ?? 'CONFIRMED',
            );
          }).toList();
        }
      } catch (_) {
        // Fallback to empty transaction list if contributions endpoint is empty
      }

      return MandalDashboardData(
        mandalName: 'Mandal Organization',
        festivalYear: 'Utsav 2026',
        currentBalancePaise: netBalancePaise,
        todaysCollectionPaise: todayTotalCollectedPaise,
        totalCollectionPaise: totalCollectionsPaise,
        totalExpensesPaise: paidExpensesPaise,
        pendingBillsCount: 0,
        pendingBillsAmountPaise: 0,
        pendingReceiptsCount: 0,
        activeVolunteersCount: activeVolunteers,
        totalDonorsCount: totalDonorsCount,
        upcomingEventsCount: activeEvents,
        transactions: recentTransactions,
      );
    });
  }
}
