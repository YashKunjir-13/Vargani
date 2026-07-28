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
}
