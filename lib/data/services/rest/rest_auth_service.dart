import 'package:dio/dio.dart';
import 'package:tennis_cup/data/auth/auth_token_store.dart';

class TokenResponse {
  final String accessToken;
  final String refreshToken;

  const TokenResponse({required this.accessToken, required this.refreshToken});

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}

class RestAuthService {
  final Dio _dio;
  final AuthTokenStore _tokenStore;

  RestAuthService({required Dio dio, required AuthTokenStore tokenStore})
      : _dio = dio,
        _tokenStore = tokenStore;

  Future<TokenResponse> login({
    required String login,
    required String password,
  }) async {
    final response = await _dio.post(
      '/api/v1/auth/login',
      data: {'login': login, 'password': password},
    );
    final tokens = TokenResponse.fromJson(response.data as Map<String, dynamic>);
    await _tokenStore.saveTokens(
      access: tokens.accessToken,
      refresh: tokens.refreshToken,
    );
    return tokens;
  }

  Future<void> register({
    required String login,
    required String password,
    required String firstName,
    required String lastName,
    String? patronymicName,
    String? birthDate,
    String? gender,
    String? country,
    String? city,
  }) async {
    await _dio.post('/api/v1/auth/register', data: {
      'login': login,
      'password': password,
      'role': 'PLAYER',
      'firstName': firstName,
      'lastName': lastName,
      if (patronymicName != null) 'patronymicName': patronymicName,
      if (birthDate != null) 'birthDate': birthDate,
      if (gender != null) 'gender': gender,
      if (country != null) 'country': country,
      if (city != null) 'city': city,
    });
  }

  Future<String> refreshAccessToken() async {
    final refreshToken = await _tokenStore.getRefreshToken();
    if (refreshToken == null) throw Exception('No refresh token');

    final response = await _dio.post(
      '/api/v1/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    final tokens = TokenResponse.fromJson(response.data as Map<String, dynamic>);
    await _tokenStore.saveTokens(
      access: tokens.accessToken,
      refresh: tokens.refreshToken,
    );
    return tokens.accessToken;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final accessToken = await _tokenStore.getAccessToken();
    if (accessToken == null) throw Exception('Not authenticated');

    await _dio.post(
      '/api/v1/auth/change-password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
  }

  Future<void> logout() async {
    final refreshToken = await _tokenStore.getRefreshToken();
    if (refreshToken == null) return;

    try {
      await _dio.post(
        '/api/v1/auth/logout',
        data: {'refreshToken': refreshToken},
      );
    } finally {
      await _tokenStore.clearAll();
    }
  }
}
