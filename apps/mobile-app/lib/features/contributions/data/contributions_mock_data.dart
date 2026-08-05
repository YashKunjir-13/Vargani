import '../models/contribution.dart';

List<Contribution> buildMockContributions() {
  final now = DateTime.now();
  return [
    Contribution(
      id: 'contrib-1',
      contributorName: 'Meera Kelkar',
      contact: '9822334455',
      date: now.subtract(const Duration(days: 2)),
      donationType: DonationType.gold,
      itemDescription: '1 gold chain',
      weightGrams: 8.5,
      estimatedValue: 62000,
      certificatePhotoUrl: 'local://certificate-1.jpg',
      recordedBy: 'Volunteer: Sneha Patil',
      status: ContributionStatus.receipted,
    ),
    Contribution(
      id: 'contrib-2',
      contributorName: 'Om Electronics',
      date: now.subtract(const Duration(days: 4)),
      donationType: DonationType.electronicGoods,
      itemDescription: '2 tube lights + speaker set',
      recordedBy: 'Volunteer: Rahul Jadhav',
      status: ContributionStatus.receipted,
    ),
    Contribution(
      id: 'contrib-3',
      contributorName: 'Anjali Sawant',
      contact: '9765123456',
      date: now.subtract(const Duration(days: 5)),
      donationType: DonationType.silver,
      itemDescription: 'Silver coin, 10 pieces',
      weightGrams: 100,
      estimatedValue: 75000,
      recordedBy: 'Treasurer: Vikram Rao',
      status: ContributionStatus.receipted,
    ),
  ];
}
