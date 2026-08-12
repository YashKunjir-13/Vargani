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
  final String? contactNumber;
  final double amount;
  final DateTime issuedDate;
  final String mandalName;
  final ReceiptStatus status;
  final WhatsappDeliveryStatus whatsappDeliveryStatus;
  final int whatsappRetryCount;
  final String? voidReason;
  final String? pdfUrl;

  const Receipt({
    required this.id,
    required this.receiptNumber,
    required this.paymentId,
    required this.donorName,
    this.contactNumber,
    required this.amount,
    required this.issuedDate,
    required this.mandalName,
    required this.status,
    required this.whatsappDeliveryStatus,
    this.whatsappRetryCount = 0,
    this.voidReason,
    this.pdfUrl,
  });

  Receipt copyWith({
    ReceiptStatus? status,
    WhatsappDeliveryStatus? whatsappDeliveryStatus,
    int? whatsappRetryCount,
    String? voidReason,
    String? pdfUrl,
    String? contactNumber,
  }) {
    return Receipt(
      id: id,
      receiptNumber: receiptNumber,
      paymentId: paymentId,
      donorName: donorName,
      contactNumber: contactNumber ?? this.contactNumber,
      amount: amount,
      issuedDate: issuedDate,
      mandalName: mandalName,
      status: status ?? this.status,
      whatsappDeliveryStatus: whatsappDeliveryStatus ?? this.whatsappDeliveryStatus,
      whatsappRetryCount: whatsappRetryCount ?? this.whatsappRetryCount,
      voidReason: voidReason ?? this.voidReason,
      pdfUrl: pdfUrl ?? this.pdfUrl,
    );
  }

  factory Receipt.fromJson(Map<String, dynamic> json) {
    double parsedAmount = 0.0;
    if (json.containsKey('amountPaise') && json['amountPaise'] != null) {
      parsedAmount = (double.tryParse(json['amountPaise'].toString()) ?? 0.0) / 100.0;
    } else {
      final rawAmount = json['amountSnapshot'] ?? json['amount'];
      parsedAmount = (rawAmount is num)
          ? rawAmount.toDouble()
          : (double.tryParse(rawAmount?.toString() ?? '0') ?? 0.0);
    }

    final rawStatus = json['status'] as String? ?? 'ACTIVE';
    final status = rawStatus == 'VOIDED' ? ReceiptStatus.voided : ReceiptStatus.active;

    final rawWaStatus = json['whatsappDeliveryStatus'] as String? ?? 'PENDING';
    WhatsappDeliveryStatus whatsappDeliveryStatus;
    switch (rawWaStatus) {
      case 'SENT':
        whatsappDeliveryStatus = WhatsappDeliveryStatus.sent;
        break;
      case 'FAILED':
        whatsappDeliveryStatus = WhatsappDeliveryStatus.failed;
        break;
      case 'PENDING':
      default:
        whatsappDeliveryStatus = WhatsappDeliveryStatus.pending;
        break;
    }

    final rawIssued = json['issuedDate'] as String? ?? json['collectedAt'] as String?;

    return Receipt(
      id: json['id'] as String? ?? '',
      receiptNumber: json['receiptNumber'] as String? ?? '',
      paymentId: json['paymentId'] as String? ?? '',
      donorName: json['donorNameSnapshot'] as String? ?? json['donorName'] as String? ?? 'Authenticated Donor',
      contactNumber: json['contactSnapshot'] as String? ?? json['contactNumber'] as String? ?? json['contact'] as String?,
      amount: parsedAmount,
      issuedDate: rawIssued != null ? (DateTime.tryParse(rawIssued) ?? DateTime.now()) : DateTime.now(),
      mandalName: json['mandalNameSnapshot'] as String? ?? json['mandalName'] as String? ?? json['organizationName'] as String? ?? 'Mandal Trust',
      status: status,
      whatsappDeliveryStatus: whatsappDeliveryStatus,
      whatsappRetryCount: json['whatsappRetryCount'] as int? ?? 0,
      voidReason: json['voidReason'] as String?,
      pdfUrl: json['pdfUrl'] as String?,
    );
  }
}
