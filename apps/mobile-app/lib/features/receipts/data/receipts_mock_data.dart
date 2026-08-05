import '../models/receipt.dart';

List<Receipt> buildMockReceipts() {
  final now = DateTime.now();
  return [
    Receipt(
      id: 'rcpt-1',
      receiptNumber: 'RCPT-2026-000043',
      paymentId: 'pay-3',
      donorName: 'Suresh Patil',
      amount: 11000,
      issuedDate: now.subtract(const Duration(days: 1)),
      mandalName: 'Shree Ganesh Mandal',
      status: ReceiptStatus.active,
      whatsappDeliveryStatus: WhatsappDeliveryStatus.sent,
    ),
    Receipt(
      id: 'rcpt-2',
      receiptNumber: 'RCPT-2026-000044',
      paymentId: 'pay-4',
      donorName: 'Priya Joshi',
      amount: 501,
      issuedDate: now.subtract(const Duration(days: 2)),
      mandalName: 'Shree Ganesh Mandal',
      status: ReceiptStatus.active,
      whatsappDeliveryStatus: WhatsappDeliveryStatus.failed,
      whatsappRetryCount: 2,
    ),
    Receipt(
      id: 'rcpt-3',
      receiptNumber: 'RCPT-2026-000038',
      paymentId: 'pay-legacy-1',
      donorName: 'Mahesh Gokhale',
      amount: 3000,
      issuedDate: now.subtract(const Duration(days: 6)),
      mandalName: 'Shree Ganesh Mandal',
      status: ReceiptStatus.voided,
      whatsappDeliveryStatus: WhatsappDeliveryStatus.sent,
      voidReason: 'Underlying payment voided -- duplicate entry',
    ),
  ];
}
