/// Centralized test factories for Flutter widget and unit tests.
/// Provides deterministic mock data with type-safe overrides.

class MockOrganizationData {
  final String id;
  final String name;
  final String code;
  final String city;
  final String state;

  const MockOrganizationData({
    this.id = '00000000-0000-4000-a000-000000000001',
    this.name = 'Shree Siddhivinayak Ganpati Mandal',
    this.code = 'MANDAL01',
    this.city = 'Pune',
    this.state = 'Maharashtra',
  });
}

class MockDonorData {
  final String id;
  final String name;
  final String phone;
  final double totalContributed;

  const MockDonorData({
    this.id = 'donor-1',
    this.name = 'Ramesh Shivaji Patil',
    this.phone = '+91 98765 43210',
    this.totalContributed = 25000.0,
  });
}

class MockContributionData {
  final String id;
  final String contributorName;
  final String donationType;
  final double amountOrValue;
  final String status;
  final String date;

  const MockContributionData({
    this.id = 'contrib-1',
    this.contributorName = 'Ramesh Shinde',
    this.donationType = 'Gold',
    this.amountOrValue = 75000.0,
    this.status = 'RECORDED',
    this.date = '2026-08-01',
  });
}

class MockBillData {
  final String id;
  final String billNumber;
  final String receiverName;
  final double amount;
  final String status;
  final String taskOrField;

  const MockBillData({
    this.id = 'bill-1',
    this.billNumber = 'BILL-2026-000001',
    this.receiverName = 'Ganesh Decorators',
    this.amount = 15000.0,
    this.status = 'DRAFT',
    this.taskOrField = 'Mandap Decoration',
  });
}

class MockPaymentData {
  final String id;
  final String donorName;
  final double amount;
  final String channel;
  final String status;

  const MockPaymentData({
    this.id = 'payment-1',
    this.donorName = 'Ramesh Kulkarni',
    this.amount = 501.0,
    this.channel = 'QR_CODE',
    this.status = 'PENDING_MATCH',
  });
}
