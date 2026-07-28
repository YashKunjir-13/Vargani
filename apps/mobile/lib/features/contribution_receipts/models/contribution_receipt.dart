enum ContributionReceiptWhatsappStatus { pending, sent, failed }

enum ContributionReceiptStatus { active, voided }

extension ContributionReceiptWhatsappStatusLabel on ContributionReceiptWhatsappStatus {
  String get label => switch (this) {
        ContributionReceiptWhatsappStatus.pending => 'Pending',
        ContributionReceiptWhatsappStatus.sent => 'Sent',
        ContributionReceiptWhatsappStatus.failed => 'Failed',
      };
}

extension ContributionReceiptStatusLabel on ContributionReceiptStatus {
  String get label => switch (this) {
        ContributionReceiptStatus.active => 'Active',
        ContributionReceiptStatus.voided => 'Voided',
      };
}

/// Mirrors backend PaymentReceipt (Phase 3) but with its OWN independent
/// numbering sequence -- contributionReceiptNumber (CRCPT-) never shares a
/// counter with the monetary receiptNumber (RCPT-), even within the same
/// organizationId+festivalYear. See ContributionReceiptsNotifier's separate
/// _sequence field vs ReceiptsNotifier's.
class ContributionReceipt {
  final String id;
  final String contributionReceiptNumber;
  final String contributionId;
  final String contributorName;
  final String donationType;
  final DateTime issuedDate;
  final String mandalName;
  final String? templateVersionId;
  final ContributionReceiptStatus status;
  final ContributionReceiptWhatsappStatus whatsappDeliveryStatus;
  final int whatsappRetryCount;
  final String? voidReason;

  const ContributionReceipt({
    required this.id,
    required this.contributionReceiptNumber,
    required this.contributionId,
    required this.contributorName,
    required this.donationType,
    required this.issuedDate,
    required this.mandalName,
    this.templateVersionId,
    required this.status,
    required this.whatsappDeliveryStatus,
    this.whatsappRetryCount = 0,
    this.voidReason,
  });

  ContributionReceipt copyWith({
    ContributionReceiptStatus? status,
    ContributionReceiptWhatsappStatus? whatsappDeliveryStatus,
    int? whatsappRetryCount,
    String? voidReason,
  }) {
    return ContributionReceipt(
      id: id,
      contributionReceiptNumber: contributionReceiptNumber,
      contributionId: contributionId,
      contributorName: contributorName,
      donationType: donationType,
      issuedDate: issuedDate,
      mandalName: mandalName,
      templateVersionId: templateVersionId,
      status: status ?? this.status,
      whatsappDeliveryStatus: whatsappDeliveryStatus ?? this.whatsappDeliveryStatus,
      whatsappRetryCount: whatsappRetryCount ?? this.whatsappRetryCount,
      voidReason: voidReason ?? this.voidReason,
    );
  }
}
