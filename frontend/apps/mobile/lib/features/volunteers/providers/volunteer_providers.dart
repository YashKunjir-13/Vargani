import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_volunteer_repository.dart';
import '../data/volunteer_repository.dart';
import '../models/volunteer.dart';
import '../models/volunteer_assignment.dart';

final volunteerRepositoryProvider = Provider<VolunteerRepository>((ref) => MockVolunteerRepository());

class VolunteerListState {
  const VolunteerListState({this.search = '', this.status, this.type});

  final String search;
  final VolunteerStatus? status;
  final VolunteerType? type;

  VolunteerListState copyWith({
    String? search,
    VolunteerStatus? status,
    bool clearStatus = false,
    VolunteerType? type,
    bool clearType = false,
  }) {
    return VolunteerListState(
      search: search ?? this.search,
      status: clearStatus ? null : (status ?? this.status),
      type: clearType ? null : (type ?? this.type),
    );
  }
}

class VolunteerListNotifier extends Notifier<VolunteerListState> {
  @override
  VolunteerListState build() => const VolunteerListState();

  void updateSearch(String search) {
    state = state.copyWith(search: search);
  }

  void updateStatus(VolunteerStatus? status) {
    if (status == null) {
      state = state.copyWith(clearStatus: true);
    } else {
      state = state.copyWith(status: status);
    }
  }

  void updateType(VolunteerType? type) {
    if (type == null) {
      state = state.copyWith(clearType: true);
    } else {
      state = state.copyWith(type: type);
    }
  }
}

final volunteerListControllerProvider = NotifierProvider<VolunteerListNotifier, VolunteerListState>(
  VolunteerListNotifier.new,
);

final volunteerListProvider = FutureProvider<List<Volunteer>>((ref) async {
  final state = ref.watch(volunteerListControllerProvider);
  final repository = ref.watch(volunteerRepositoryProvider);
  return repository.getVolunteers(search: state.search, status: state.status, type: state.type);
});

final volunteerDetailProvider = FutureProvider.family<Volunteer?, String>((ref, volunteerId) async {
  final repository = ref.watch(volunteerRepositoryProvider);
  return repository.getVolunteerById(volunteerId);
});

final volunteerAssignmentsProvider = FutureProvider.family<List<VolunteerAssignment>, String>((ref, volunteerId) async {
  final repository = ref.watch(volunteerRepositoryProvider);
  return repository.getAssignmentsForVolunteer(volunteerId);
});
