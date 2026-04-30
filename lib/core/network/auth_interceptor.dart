import 'package:dio/dio.dart';
import 'package:tennis_cup/features/auth/data/auth_token_store.dart';

typedef TokenRefreshCallback = Future<String> Function();

class AuthInterceptor extends QueuedInterceptorsWrapper {
  final AuthTokenStore _tokenStore;
  final Dio _dio;
  final TokenRefreshCallback _refreshToken;

  AuthInterceptor({
    required AuthTokenStore tokenStore,
    required Dio dio,
    required TokenRefreshCallback refreshToken,
  })  : _tokenStore = tokenStore,
        _dio = dio,
        _refreshToken = refreshToken;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStore.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        final newToken = await _refreshToken();
        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer $newToken';
        final response = await _dio.fetch(options);
        handler.resolve(response);
      } catch (_) {
        await _tokenStore.clearAll();
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }
}
