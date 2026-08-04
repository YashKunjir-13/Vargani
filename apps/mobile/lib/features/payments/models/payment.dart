/// Mirrors backend PaymentChannel (apps/api/src/payments) -- digital-only
/// capture, no Cash value exists here by design.
enum PaymentChannel { inApp, qrCode }

/// Mirrors backend PaymentStatus.
enum PaymentStatus { pendingMatch, confirmed, receipted, voided }

extension PaymentChannelLabel on PaymentChannel {
  String get label => switch (this) {
        PaymentChannel.inApp => 'In-App',
        PaymentChannel.qrCode => 'QR Code',
      };

  String get toApiString => switch (this) {
        PaymentChannel.inApp => 'IN_APP',
        PaymentChannel.qrCode => 'QR_CODE',
      };
}

extension PaymentStatusLabel on PaymentStatus {
  String get label => switch (this) {
        PaymentStatus.pendingMatch => 'Pending Match',
        PaymentStatus.confirmed => 'Confirmed',
        PaymentStatus.receipted => 'Receipted',
        PaymentStatus.voided => 'Voided',
      };
}

class Payment {
  final String id;
  final String donorName;
  final String? address;
  final String? contact;
  final double amount;
  final DateTime paymentDateTime;
  final PaymentChannel channel;
  final PaymentStatus status;
  final String? collectedBy;
  final String? matchedBy;
  final String? voidReason;

  const Payment({
    required this.id,
    required this.donorName,
    this.address,
    this.contact,
    required this.amount,
    required this.paymentDateTime,
    required this.channel,
    required this.status,
    this.collectedBy,
    this.matchedBy,
    this.voidReason,
  });

  Payment copyWith({
    PaymentStatus? status,
    String? matchedBy,
    String? voidReason,
  }) {
    return Payment(
      id: id,
      donorName: donorName,
      address: address,
      contact: contact,
      amount: amount,
      paymentDateTime: paymentDateTime,
      channel: channel,
      status: status ?? this.status,
      collectedBy: collectedBy,
      matchedBy: matchedBy ?? this.matchedBy,
      voidReason: voidReason ?? this.voidReason,
    );
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'];
    final parsedAmount = (rawAmount is num)
        ? rawAmount.toDouble()
        : (double.tryParse(rawAmount?.toString() ?? '0') ?? 0.0);

    final rawChannel = json['channel'] as String? ?? 'QR_CODE';
    final channel = rawChannel == 'IN_APP' ? PaymentChannel.inApp : PaymentChannel.qrCode;

    final rawStatus = json['status'] as String? ?? 'PENDING_MATCH';
    PaymentStatus status;
    switch (rawStatus) {
      case 'CONFIRMED':
        status = PaymentStatus.confirmed;
        break;
      case 'RECEIPTED':
        status = PaymentStatus.receipted;
        break;
      case 'VOIDED':
        status = PaymentStatus.voided;
        break;
      case 'PENDING_MATCH':
      default:
        status = PaymentStatus.pendingMatch;
        break;
    }

    final rawDateTime = json['paymentDateTime'] as String?;

    return Payment(
      id: json['id'] as String? ?? '',
      donorName: json['donorNameSnapshot'] as String? ?? json['donorName'] as String? ?? 'Anonymous Donor',
      address: json['addressSnapshot'] as String? ?? json['address'] as String?,
      contact: json['contactSnapshot'] as String? ?? json['contact'] as String?,
      amount: parsedAmount,
      paymentDateTime: rawDateTime != null ? DateTime.parse(rawDateTime) : DateTime.now(),
      channel: channel,
      status: status,
      collectedBy: json['collectedByUserId'] != null ? 'User: ${json['collectedByUserId']}' : json['collectedBy'] as String?,
      matchedBy: json['matchedByUserId'] != null ? 'User: ${json['matchedByUserId']}' : json['matchedBy'] as String?,
      voidReason: json['voidReason'] as String?,
    );
  }
}
