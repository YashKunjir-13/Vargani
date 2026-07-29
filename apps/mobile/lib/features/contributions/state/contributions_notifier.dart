import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../contribution_receipts/state/contribution_receipts_notifier.dart';
import '../data/contributions_mock_data.dart';
import '../models/contribution.dart';

/// Local, in-memory stand-in for ContributionsService (src/contributions).
class ContributionsNotifier extends Notifier<List<Contribution>> {
  @override
  List<Contribution> build() => buildMockContributions();

  /// The record action itself produces the Contribution Receipt --
  /// mirrors the spec exactly: no separate manual "generate" step.
  Contribution record({
    required String contributorName,
    String? contact,
    required DonationType donationType,
    String? itemDescription,
    double? weightGrams,
    double? estimatedValue,
    String? certificatePhotoUrl,
    required String recordedBy,
  }) {
    final contribution = Contribution(
      id: 'contrib-${DateTime.now().microsecondsSinceEpoch}',
      contributorName: contributorName,
      contact: contact,
      date: DateTime.now(),
      donationType: donationType,
      itemDescription: itemDescription,
      weightGrams: weightGrams,
      estimatedValue: estimatedValue,
      certificatePhotoUrl: certificatePhotoUrl,
      recordedBy: recordedBy,
      status: ContributionStatus.receipted,
    );
    state = [contribution, ...state];

    ref.read(contributionReceiptsProvider.notifier).generateForContribution(
          contributionId: contribution.id,
          contributorName: contribution.contributorName,
          donationType: contribution.donationType.label,
          templateVersionId: 'template-v1',
        );

    return contribution;
  }
}

final contributionsProvider = NotifierProvider<ContributionsNotifier, List<Contribution>>(ContributionsNotifier.new);
