import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/session/session_controller.dart';
import '../../contribution_receipts/state/contribution_receipts_notifier.dart';
import '../data/contributions_mock_data.dart';
import '../data/contributions_remote_datasource.dart';
import '../models/contribution.dart';

final contributionsRemoteDataSourceProvider =
    Provider<ContributionsRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return ContributionsRemoteDataSource(dio);
});

class ContributionsNotifier extends Notifier<List<Contribution>> {
  @override
  List<Contribution> build() {
    fetchRemote();
    return buildMockContributions();
  }

  Future<void> fetchRemote() async {
    final remote = ref.read(contributionsRemoteDataSourceProvider);
    try {
      final fetched = await remote.fetchContributions();
      if (fetched.isNotEmpty) {
        state = fetched;
      }
    } catch (_) {}
  }

  /// The record action creates the contribution record.
  Contribution record({
    required String contributorName,
    String? contact,
    required DonationType donationType,
    String? itemDescription,
    double? weightGrams,
    double? quantity,
    String? unit,
    double? estimatedValue,
    String? notes,
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
      quantity: quantity,
      unit: unit,
      estimatedValue: estimatedValue,
      notes: notes,
      certificatePhotoUrl: certificatePhotoUrl,
      recordedBy: recordedBy,
      status: ContributionStatus.receipted,
    );
    state = [contribution, ...state];

    _recordRemote(
      localId: contribution.id,
      contributorName: contributorName,
      contact: contact,
      donationType: donationType,
      itemDescription: itemDescription,
      weightGrams: weightGrams,
      quantity: quantity,
      unit: unit,
      estimatedValue: estimatedValue,
      notes: notes,
      certificatePhotoUrl: certificatePhotoUrl,
    );

    ref.read(contributionReceiptsProvider.notifier).generateForContribution(
          contributionId: contribution.id,
          contributorName: contribution.contributorName,
          donationType: contribution.donationType.label,
          templateVersionId: 'template-v1',
        );

    return contribution;
  }

  Future<void> _recordRemote({
    required String localId,
    required String contributorName,
    String? contact,
    required DonationType donationType,
    String? itemDescription,
    double? weightGrams,
    double? quantity,
    String? unit,
    double? estimatedValue,
    String? notes,
    String? certificatePhotoUrl,
  }) async {
    final remote = ref.read(contributionsRemoteDataSourceProvider);
    try {
      final created = await remote.createContribution(
        contributorName: contributorName,
        contact: contact,
        donationType: donationType,
        itemDescription: itemDescription,
        weightGrams: weightGrams,
        quantity: quantity,
        unit: unit,
        estimatedValue: estimatedValue,
        notes: notes,
        certificatePhotoUrl: certificatePhotoUrl,
      );
      state = [
        for (final c in state)
          if (c.id == localId) created else c,
      ];
      await fetchRemote();
    } catch (_) {}
  }

  void update(
    String id, {
    String? contributorName,
    String? contact,
    DonationType? donationType,
    String? itemDescription,
    double? weightGrams,
    double? estimatedValue,
    String? certificatePhotoUrl,
  }) {
    state = [
      for (final c in state)
        if (c.id == id && c.status == ContributionStatus.recorded)
          c.copyWith(
            contributorName: contributorName,
            contact: contact,
            donationType: donationType,
            itemDescription: itemDescription,
            weightGrams: weightGrams,
            estimatedValue: estimatedValue,
            certificatePhotoUrl: certificatePhotoUrl,
          )
        else
          c,
    ];
    _updateRemote(
      id,
      contributorName: contributorName,
      contact: contact,
      donationType: donationType,
      itemDescription: itemDescription,
      weightGrams: weightGrams,
      estimatedValue: estimatedValue,
      certificatePhotoUrl: certificatePhotoUrl,
    );
  }

  Future<void> _updateRemote(
    String id, {
    String? contributorName,
    String? contact,
    DonationType? donationType,
    String? itemDescription,
    double? weightGrams,
    double? estimatedValue,
    String? certificatePhotoUrl,
  }) async {
    final remote = ref.read(contributionsRemoteDataSourceProvider);
    try {
      final updated = await remote.updateContribution(
        id,
        contributorName: contributorName,
        contact: contact,
        donationType: donationType,
        itemDescription: itemDescription,
        weightGrams: weightGrams,
        estimatedValue: estimatedValue,
        certificatePhotoUrl: certificatePhotoUrl,
      );
      state = [
        for (final c in state)
          if (c.id == id) updated else c
      ];
    } catch (_) {}
  }

  void delete(String id) {
    state = state
        .where((c) => !(c.id == id && c.status == ContributionStatus.recorded))
        .toList();
    _deleteRemote(id);
  }

  Future<void> _deleteRemote(String id) async {
    final remote = ref.read(contributionsRemoteDataSourceProvider);
    try {
      await remote.deleteContribution(id);
    } catch (_) {}
  }
}

final contributionsProvider =
    NotifierProvider<ContributionsNotifier, List<Contribution>>(
        ContributionsNotifier.new);
