enum DateRangeFilter {
  entireFestival,
  today,
  thisWeek,
  thisMonth,
  custom
}

class FinancialMetrics {
  final int totalInflowPaise;
  final int totalOutflowPaise;

  const FinancialMetrics({
    required this.totalInflowPaise,
    required this.totalOutflowPaise,
  });

  int get netBalancePaise => totalInflowPaise - totalOutflowPaise;
}

class AuditSummary {
  final int totalEvents;
  final int passedRecords;
  final int warnings;
  final int criticalFindings;

  const AuditSummary({
    this.totalEvents = 0,
    this.passedRecords = 0,
    this.warnings = 0,
    this.criticalFindings = 0,
  });
}

class BillSummary {
  final int totalBills;
  final int totalBilledPaise;
  final int pendingBills;
  final int approvedBills;
  final int paidBills;

  const BillSummary({
    this.totalBills = 0,
    this.totalBilledPaise = 0,
    this.pendingBills = 0,
    this.approvedBills = 0,
    this.paidBills = 0,
  });
}

class ReceiptSummary {
  final int totalReceipts;
  final int totalReceiptAmountPaise;
  final int todaysReceipts;

  const ReceiptSummary({
    this.totalReceipts = 0,
    this.totalReceiptAmountPaise = 0,
    this.todaysReceipts = 0,
  });
}

class SponsorshipSummary {
  final int totalSponsorships;
  final int totalSponsorshipAmountPaise;
  final int activeSponsors;

  const SponsorshipSummary({
    this.totalSponsorships = 0,
    this.totalSponsorshipAmountPaise = 0,
    this.activeSponsors = 0,
  });
}

class VendorSummary {
  final int totalVendors;
  final int activeVendors;

  const VendorSummary({
    this.totalVendors = 0,
    this.activeVendors = 0,
  });
}

class AdvertiserSummary {
  final int totalAdvertisers;
  final int advertisementPlacements;
  final int associatedRevenuePaise;

  const AdvertiserSummary({
    this.totalAdvertisers = 0,
    this.advertisementPlacements = 0,
    this.associatedRevenuePaise = 0,
  });
}

class MilestoneSummary {
  final int totalMilestones;
  final int completed;
  final int inProgress;
  final int pending;

  const MilestoneSummary({
    this.totalMilestones = 0,
    this.completed = 0,
    this.inProgress = 0,
    this.pending = 0,
  });
}

class ContributionSummary {
  final int totalContributions;
  final Map<String, int> breakdownByType;

  const ContributionSummary({
    this.totalContributions = 0,
    this.breakdownByType = const {},
  });
}

class AnalyticalDashboardData {
  final FinancialMetrics financialMetrics;
  final AuditSummary auditSummary;
  final BillSummary billSummary;
  final ReceiptSummary receiptSummary;
  final SponsorshipSummary sponsorshipSummary;
  final VendorSummary vendorSummary;
  final AdvertiserSummary advertiserSummary;
  final MilestoneSummary milestoneSummary;
  final ContributionSummary contributionSummary;
  final DateTime? startDate;
  final DateTime? endDate;

  const AnalyticalDashboardData({
    required this.financialMetrics,
    required this.auditSummary,
    required this.billSummary,
    required this.receiptSummary,
    required this.sponsorshipSummary,
    required this.vendorSummary,
    required this.advertiserSummary,
    required this.milestoneSummary,
    required this.contributionSummary,
    this.startDate,
    this.endDate,
  });
}
