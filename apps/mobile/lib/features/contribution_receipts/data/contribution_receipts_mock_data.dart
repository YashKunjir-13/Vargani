import '../models/contribution_receipt.dart';

List<ContributionReceipt> buildMockContributionReceipts() {
  final now = DateTime.now();
  return [
    ContributionReceipt(
      id: 'crcpt-1',
      contributionReceiptNumber: 'CRCPT-2026-000001',
      contributionId: 'contrib-1',
      contributorName: 'Meera Kelkar',
      donationType: 'Gold',
      issuedDate: now.subtract(const Duration(days: 2)),
      mandalName: 'Shree Ganesh Mandal',
      templateVersionId: 'template-v1',
      status: ContributionReceiptStatus.active,
      whatsappDeliveryStatus: ContributionReceiptWhatsappStatus.sent,
    ),
    ContributionReceipt(
      id: 'crcpt-2',
      contributionReceiptNumber: 'CRCPT-2026-000002',
      contributionId: 'contrib-2',
      contributorName: 'Om Electronics',
      donationType: 'Electronic Goods',
      issuedDate: now.subtract(const Duration(days: 4)),
      mandalName: 'Shree Ganesh Mandal',
      status: ContributionReceiptStatus.active,
      whatsappDeliveryStatus: ContributionReceiptWhatsappStatus.pending,
    ),
    ContributionReceipt(
      id: 'crcpt-3',
      contributionReceiptNumber: 'CRCPT-2026-000003',
      contributionId: 'contrib-3',
      contributorName: 'Anjali Sawant',
      donationType: 'Silver',
      issuedDate: now.subtract(const Duration(days: 5)),
      mandalName: 'Shree Ganesh Mandal',
      templateVersionId: 'template-v1',
      status: ContributionReceiptStatus.active,
      whatsappDeliveryStatus: ContributionReceiptWhatsappStatus.sent,
    ),
  ];
}
