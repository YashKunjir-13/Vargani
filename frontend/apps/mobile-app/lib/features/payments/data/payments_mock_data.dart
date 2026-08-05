import '../models/payment.dart';

List<Payment> buildMockPayments() {
  final now = DateTime.now();
  return [
    Payment(
      id: 'pay-1',
      donorName: 'Ramesh Kulkarni',
      contact: '9876543210',
      amount: 5100,
      paymentDateTime: now.subtract(const Duration(hours: 2)),
      channel: PaymentChannel.qrCode,
      status: PaymentStatus.pendingMatch,
      collectedBy: 'Volunteer: Sneha Patil',
    ),
    Payment(
      id: 'pay-2',
      donorName: 'Anita Deshmukh',
      contact: '9822011223',
      address: 'Flat 12, Shivaji Nagar',
      amount: 2100,
      paymentDateTime: now.subtract(const Duration(hours: 5)),
      channel: PaymentChannel.qrCode,
      status: PaymentStatus.pendingMatch,
      collectedBy: 'Volunteer: Rahul Jadhav',
    ),
    Payment(
      id: 'pay-3',
      donorName: 'Suresh Patil',
      amount: 11000,
      paymentDateTime: now.subtract(const Duration(days: 1)),
      channel: PaymentChannel.inApp,
      status: PaymentStatus.receipted,
      matchedBy: 'System (Razorpay webhook)',
    ),
    Payment(
      id: 'pay-4',
      donorName: 'Priya Joshi',
      contact: '9765432109',
      amount: 501,
      paymentDateTime: now.subtract(const Duration(days: 2)),
      channel: PaymentChannel.qrCode,
      status: PaymentStatus.receipted,
      collectedBy: 'Treasurer: Vikram Rao',
      matchedBy: 'Treasurer: Vikram Rao',
    ),
    Payment(
      id: 'pay-5',
      donorName: 'Mahesh Gokhale',
      amount: 3000,
      paymentDateTime: now.subtract(const Duration(days: 3)),
      channel: PaymentChannel.qrCode,
      status: PaymentStatus.voided,
      collectedBy: 'Volunteer: Sneha Patil',
      voidReason: 'Duplicate entry -- already recorded as pay-4',
    ),
  ];
}
