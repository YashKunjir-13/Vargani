/// Mirrors backend WhatsAppDeliveryStatus (apps/api/src/receipts).
enum WhatsappDeliveryStatus { pending, sent, failed }

/// Mirrors backend PaymentReceiptStatus.
enum ReceiptStatus { active, voided }

extension WhatsappDeliveryStatusLabel on WhatsappDeliveryStatus {
  String get label => switch (this) {
        WhatsappDeliveryStatus.pending => 'Pending',
        WhatsappDeliveryStatus.sent => 'Sent',
        WhatsappDeliveryStatus.failed => 'Failed',
      };
}

extension ReceiptStatusLabel on ReceiptStatus {
  String get label => switch (this) {
        ReceiptStatus.active => 'Active',
        ReceiptStatus.voided => 'Voided',
      };
}

class Receipt {
  final String id;
  final String receiptNumber;
  final String paymentId;
  final String donorName;
  final double amount;
  final DateTime issuedDate;
  final String mandalName;
  final ReceiptStatus status;
  final WhatsappDeliveryStatus whatsappDeliveryStatus;
  final int whatsappRetryCount;
  final String? voidReason;

  const Receipt({
    required this.id,
    required this.receiptNumber,
    required this.paymentId,
    required this.donorName,
    required this.amount,
    required this.issuedDate,
    required this.mandalName,
    required this.status,
    required this.whatsappDeliveryStatus,
    this.whatsappRetryCount = 0,
    this.voidReason,
  });

  Receipt copyWith({
    ReceiptStatus? status,
    WhatsappDeliveryStatus? whatsappDeliveryStatus,
    int? whatsappRetryCount,
    String? voidReason,
  }) {
    return Receipt(
      id: id,
      receiptNumber: receiptNumber,
      paymentId: paymentId,
      donorName: donorName,
      amount: amount,
      issuedDate: issuedDate,
      mandalName: mandalName,
      status: status ?? this.status,
      whatsappDeliveryStatus: whatsappDeliveryStatus ?? this.whatsappDeliveryStatus,
      whatsappRetryCount: whatsappRetryCount ?? this.whatsappRetryCount,
      voidReason: voidReason ?? this.voidReason,
    );
  }
}
