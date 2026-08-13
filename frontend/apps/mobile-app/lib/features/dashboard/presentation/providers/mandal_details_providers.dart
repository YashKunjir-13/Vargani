import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pauti_pustak_mobile/core/session/session_controller.dart';
import 'package:pauti_pustak_mobile/features/dashboard/models/organization_details_model.dart';

final mandalDetailsProvider =
    FutureProvider.family<PublicOrganizationDetails, String>(
        (ref, organizationId) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/organizations/$organizationId/public');

  final dynamic resData = response.data;
  Map<String, dynamic> dataMap = {};
  if (resData is Map<String, dynamic> && resData.containsKey('data')) {
    dataMap = resData['data'] as Map<String, dynamic>;
  } else if (resData is Map<String, dynamic>) {
    dataMap = resData;
  }

  return PublicOrganizationDetails.fromJson(dataMap);
});
