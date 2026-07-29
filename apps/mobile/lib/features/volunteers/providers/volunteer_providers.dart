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

  VolunteerListState copyWith({String? search, VolunteerStatus? status, VolunteerType? type}) {
    return VolunteerListState(
      search: search ?? this.search,
      status: status ?? this.status,
      type: type ?? this.type,
    );
  }
}

class VolunteerListController extends StateNotifier<VolunteerListState> {
  VolunteerListController() : super(const VolunteerListState());

  void updateSearch(String search) {
    state = state.copyWith(search: search);
  }

  void updateStatus(VolunteerStatus? status) {
    state = state.copyWith(status: status);
  }

  void updateType(VolunteerType? type) {
    state = state.copyWith(type: type);
  }
}

final volunteerListControllerProvider = StateNotifierProvider<VolunteerListController, VolunteerListState>(
  (ref) => VolunteerListController(),
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
