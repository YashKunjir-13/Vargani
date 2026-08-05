import '../../models/analytics_models.dart';
import 'analytics_repository.dart';

import '../../../bills/data/bills_mock_data.dart';
import '../../../bills/models/bill.dart';
import '../../../receipts/data/receipts_mock_data.dart';
import '../../../contributions/data/contributions_mock_data.dart';
import '../../../vendors/data/mock_vendor_repository.dart';
import '../../../vendors/models/vendor.dart';
import '../../../sponsorship_advertisement/data/mock_sponsorship_repository.dart';
import '../../../sponsorship_advertisement/data/mock_advertisement_repository.dart';
import '../../../sponsorship_advertisement/models/sponsorship.dart';
import '../../../audit_logs/data/repositories/mock_audit_repository.dart';
import '../../../../shared/ui_kit/chips/severity_badge.dart'; // Provides Severity
import '../../../milestones/data/repositories/mock_milestone_repository.dart';

class MockAnalyticsRepository implements AnalyticsRepository {
  @override
  Future<AnalyticalDashboardData> getDashboardData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final auditRepo = MockAuditRepository();
    final vendorRepo = MockVendorRepository();
    final sponsorRepo = MockSponsorshipRepository();
    final adRepo = MockAdvertisementRepository();
    final milestoneRepo = MockMilestoneRepository();

    final bills = buildMockBills();
    final receipts = buildMockReceipts();
    final contributions = buildMockContributions();

    final audits = await auditRepo.getAuditLogs();
    final vendors = await vendorRepo.getVendors();
    final sponsorships = await sponsorRepo.getSponsorships();
    final advertisements = await adRepo.getAdvertisements();
    final milestones = milestoneRepo.getAllMilestones();

    bool isWithinRange(DateTime? date) {
      if (date == null) return true;
      if (startDate != null && date.isBefore(startDate)) return false;
      if (endDate != null && date.isAfter(endDate.add(const Duration(days: 1)))) return false;
      return true;
    }

    // 1. BILLS
    final filteredBills = bills.where((b) => isWithinRange(b.date)).toList();
    int totalBilledPaise = 0;
    int pendingBills = 0;
    int approvedBills = 0;
    int paidBills = 0;
    for (var bill in filteredBills) {
      totalBilledPaise += (bill.amount * 100).toInt();
      if (bill.status == BillStatus.pendingApproval) pendingBills++;
      if (bill.status == BillStatus.approved) approvedBills++;
      if (bill.status == BillStatus.paid) paidBills++;
    }
    final billSummary = BillSummary(
      totalBills: filteredBills.length,
      totalBilledPaise: totalBilledPaise,
      pendingBills: pendingBills,
      approvedBills: approvedBills,
      paidBills: paidBills,
    );

    // 2. RECEIPTS
    final filteredReceipts = receipts.where((r) => isWithinRange(r.issuedDate)).toList();
    int totalReceiptAmountPaise = 0;
    int todaysReceipts = 0;
    final now = DateTime.now();
    for (var r in filteredReceipts) {
      totalReceiptAmountPaise += (r.amount * 100).toInt();
      if (r.issuedDate.year == now.year && r.issuedDate.month == now.month && r.issuedDate.day == now.day) {
        todaysReceipts++;
      }
    }
    final receiptSummary = ReceiptSummary(
      totalReceipts: filteredReceipts.length,
      totalReceiptAmountPaise: totalReceiptAmountPaise,
      todaysReceipts: todaysReceipts,
    );

    // 3. CONTRIBUTIONS
    final filteredContributions = contributions.where((c) => isWithinRange(c.date)).toList();
    final Map<String, int> breakdown = {};
    for (var c in filteredContributions) {
      final t = c.donationType.name;
      breakdown[t] = (breakdown[t] ?? 0) + 1;
    }
    final contributionSummary = ContributionSummary(
      totalContributions: filteredContributions.length,
      breakdownByType: breakdown,
    );

    // 4. AUDIT
    final filteredAudits = audits.where((a) => isWithinRange(a.timestamp)).toList();
    int warnings = 0;
    int critical = 0;
    int passed = 0;
    for (var a in filteredAudits) {
      if (a.severity == Severity.high || a.severity == Severity.medium) {
        warnings++;
      } else if (a.severity == Severity.critical) {
        critical++;
      } else {
        passed++;
      }
    }
    final auditSummary = AuditSummary(
      totalEvents: filteredAudits.length,
      passedRecords: passed,
      warnings: warnings,
      criticalFindings: critical,
    );

    // 5. SPONSORSHIPS
    int sponsorPaise = 0;
    int activeSponsors = 0;
    for (var s in sponsorships) {
      sponsorPaise += s.pledgedAmountPaise;
      if (s.status == SponsorshipStatus.confirmed) activeSponsors++;
    }
    final sponsorshipSummary = SponsorshipSummary(
      totalSponsorships: sponsorships.length,
      totalSponsorshipAmountPaise: sponsorPaise,
      activeSponsors: activeSponsors,
    );

    // 6. ADVERTISEMENTS
    int adPaise = 0;
    for (var ad in advertisements) {
      adPaise += ad.amountPaise;
    }
    final advertiserSummary = AdvertiserSummary(
      totalAdvertisers: advertisements.length,
      advertisementPlacements: 0,
      associatedRevenuePaise: adPaise,
    );

    // 7. VENDORS
    final vendorSummary = VendorSummary(
      totalVendors: vendors.length,
      activeVendors: vendors.where((v) => v.status == VendorStatus.active).length,
    );

    // 8. MILESTONES
    int completed = 0;
    int inProgress = 0;
    int pending = 0;
    for (var m in milestones) {
      if (m.status == 'Completed') completed++;
      if (m.status == 'In Progress') inProgress++;
      if (m.status == 'Pending') pending++;
    }
    final milestoneSummary = MilestoneSummary(
      totalMilestones: milestones.length,
      completed: completed,
      inProgress: inProgress,
      pending: pending,
    );

    // FINANCIAL METRICS
    final metrics = FinancialMetrics(
      totalInflowPaise: receiptSummary.totalReceiptAmountPaise + sponsorshipSummary.totalSponsorshipAmountPaise + advertiserSummary.associatedRevenuePaise,
      totalOutflowPaise: billSummary.totalBilledPaise,
    );

    return AnalyticalDashboardData(
      financialMetrics: metrics,
      auditSummary: auditSummary,
      billSummary: billSummary,
      receiptSummary: receiptSummary,
      sponsorshipSummary: sponsorshipSummary,
      vendorSummary: vendorSummary,
      advertiserSummary: advertiserSummary,
      milestoneSummary: milestoneSummary,
      contributionSummary: contributionSummary,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
