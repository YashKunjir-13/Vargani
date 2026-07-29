import 'package:dio/dio.dart';

import '../../../core/network/api_error_mapper.dart';
import 'models/auth_models.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AuthSession> registerTrust({
    required String mandalTrustName,
    String? registrationNumber,
    required String presidentHeadName,
    String? addressLine1,
    required String city,
    required String state,
    required String postalCode,
    required int festivalYear,
    required String phoneNumber,
    required String password,
    required String preferredLanguage,
  }) {
    return guardApiCall(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/register/trust',
        data: {
          'mandalTrustName': mandalTrustName,
          if (registrationNumber != null && registrationNumber.isNotEmpty)
            'registrationNumber': registrationNumber,
          'presidentHeadName': presidentHeadName,
          if (addressLine1 != null && addressLine1.isNotEmpty) 'addressLine1': addressLine1,
          'city': city,
          'state': state,
          'postalCode': postalCode,
          'festivalYear': festivalYear,
          'phoneNumber': phoneNumber,
          'password': password,
          'preferredLanguage': preferredLanguage,
        },
      );
      return AuthSession.fromJson(response.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<AuthSession> registerDonor({
    required String fullName,
    String? email,
    String? panNumber,
    String? addressLine1,
    required String city,
    String? postalCode,
    required String phoneNumber,
    required String password,
    required String preferredLanguage,
  }) {
    return guardApiCall(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/register/donor',
        data: {
          'fullName': fullName,
          if (email != null && email.isNotEmpty) 'email': email,
          if (panNumber != null && panNumber.isNotEmpty) 'panNumber': panNumber,
          if (addressLine1 != null && addressLine1.isNotEmpty) 'addressLine1': addressLine1,
          'city': city,
          if (postalCode != null && postalCode.isNotEmpty) 'postalCode': postalCode,
          'phoneNumber': phoneNumber,
          'password': password,
          'preferredLanguage': preferredLanguage,
        },
      );
      return AuthSession.fromJson(response.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<AuthSession> login({required String phoneNumber, required String password, required LoginRole role}) {
    return guardApiCall(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'phoneNumber': phoneNumber, 'password': password, 'role': role.name.toUpperCase()},
      );
      return AuthSession.fromJson(response.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<({String accessToken, String refreshToken, DateTime accessTokenExpiresAt})> refresh(
    String refreshToken,
  ) {
    return guardApiCall(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final data = response.data!['data'] as Map<String, dynamic>;
      return (
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
        accessTokenExpiresAt: DateTime.parse(data['accessTokenExpiresAt'] as String),
      );
    });
  }

  Future<void> logout(String refreshToken) {
    return guardApiCall(() async {
      await _dio.post<Map<String, dynamic>>(
        '/auth/logout',
        data: {'refreshToken': refreshToken},
      );
    });
  }

  Future<AuthUser> me() {
    return guardApiCall(() async {
      final response = await _dio.get<Map<String, dynamic>>('/auth/me');
      return AuthUser.fromJson(response.data!['data'] as Map<String, dynamic>);
    });
  }
}
