import '../../models/analytics_models.dart';

abstract class AnalyticsRepository {
  Future<AnalyticalDashboardData> getDashboardData({
    DateTime? startDate,
    DateTime? endDate,
  });
}
