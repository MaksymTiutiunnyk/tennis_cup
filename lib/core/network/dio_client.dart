import 'package:dio/dio.dart';
import 'package:tennis_cup/core/network/auth_interceptor.dart';
import 'package:tennis_cup/data/auth/auth_token_store.dart';

class DioClient {
  static Dio create({
    required String baseUrl,
    required AuthTokenStore tokenStore,
    required TokenRefreshCallback refreshToken,
  }) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(AuthInterceptor(
      tokenStore: tokenStore,
      dio: dio,
      refreshToken: refreshToken,
    ));

    return dio;
  }
}
