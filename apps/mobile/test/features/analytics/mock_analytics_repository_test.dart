import 'package:flutter_test/flutter_test.dart';
import 'package:pauti_pustak_mobile/features/analytics/data/repositories/mock_analytics_repository.dart';

void main() {
  group('MockAnalyticsRepository', () {
    final repo = MockAnalyticsRepository();

    test('getDashboardData fetches aggregated data successfully', () async {
      final data = await repo.getDashboardData();

      expect(data, isNotNull);
      expect(data.financialMetrics.totalInflowPaise, greaterThanOrEqualTo(0));
      expect(data.financialMetrics.totalOutflowPaise, greaterThanOrEqualTo(0));
      expect(data.auditSummary.totalEvents, greaterThanOrEqualTo(0));
      expect(data.billSummary.totalBills, greaterThanOrEqualTo(0));
      expect(data.receiptSummary.totalReceipts, greaterThanOrEqualTo(0));
      expect(data.sponsorshipSummary.totalSponsorships, greaterThanOrEqualTo(0));
      expect(data.vendorSummary.totalVendors, greaterThanOrEqualTo(0));
      expect(data.advertiserSummary.totalAdvertisers, greaterThanOrEqualTo(0));
      expect(data.milestoneSummary.totalMilestones, greaterThanOrEqualTo(0));
      expect(data.contributionSummary.totalContributions, greaterThanOrEqualTo(0));
    });

    test('getDashboardData filters data by date range correctly', () async {
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day);
      final endDate = DateTime(now.year, now.month, now.day);

      final data = await repo.getDashboardData(startDate: startDate, endDate: endDate);

      expect(data, isNotNull);
      expect(data.startDate, equals(startDate));
      expect(data.endDate, equals(endDate));
    });
  });
}
