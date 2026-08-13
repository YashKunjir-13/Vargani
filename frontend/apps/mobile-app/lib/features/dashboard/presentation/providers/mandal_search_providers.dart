import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pauti_pustak_mobile/core/session/session_controller.dart';
import 'package:pauti_pustak_mobile/features/dashboard/models/organization_search_model.dart';

class MandalSearchNotifier
    extends Notifier<AsyncValue<List<PublicOrganization>>> {
  @override
  AsyncValue<List<PublicOrganization>> build() {
    fetchMandals();
    return const AsyncValue.loading();
  }

  Future<void> fetchMandals({String query = ''}) async {
    state = const AsyncValue.loading();
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(
        '/organizations/search',
        queryParameters: query.trim().isNotEmpty ? {'q': query.trim()} : null,
      );

      final dynamic resData = response.data;
      List<dynamic> items = [];
      if (resData is Map<String, dynamic> && resData.containsKey('data')) {
        final dataField = resData['data'];
        if (dataField is List) {
          items = dataField;
        }
      } else if (resData is List) {
        items = resData;
      }

      final mandals = items
          .map((item) =>
              PublicOrganization.fromJson(item as Map<String, dynamic>))
          .toList();

      state = AsyncValue.data(mandals);
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }
}

final mandalSearchProvider = NotifierProvider<MandalSearchNotifier,
    AsyncValue<List<PublicOrganization>>>(
  MandalSearchNotifier.new,
);
