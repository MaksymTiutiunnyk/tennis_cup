import 'package:dio/dio.dart';
import 'package:tennis_cup/generated/l10n.dart';

/// Extracts a user-friendly message from any caught exception.
/// Prioritises the backend's own error string, then maps HTTP status codes,
/// then network-level errors, falling back to a generic message.
String errorMessage(Object e) {
  if (e is DioException) return _fromDio(e);
  if (e is Exception) {
    final msg = e.toString().replaceFirst('Exception: ', '').trim();
    return msg.isNotEmpty ? msg : S.current.errorSomethingWentWrong;
  }
  return S.current.errorSomethingWentWrong;
}

String _fromDio(DioException e) {
  final data = e.response?.data;
  if (data is Map) {
    final raw = data['error'] ?? data['message'];
    if (raw is String && raw.isNotEmpty) return raw;
  }

  return switch (e.response?.statusCode) {
    400 => S.current.errorInvalidRequest,
    401 => S.current.errorSessionExpired,
    403 => S.current.errorNoPermission,
    404 => S.current.errorNotFound,
    409 => S.current.errorConflict,
    422 => S.current.errorInvalidData,
    500 => S.current.errorServerError,
    503 => S.current.errorServiceUnavailable,
    _ => _fromDioType(e),
  };
}

String _fromDioType(DioException e) => switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout =>
        S.current.errorConnectionTimeout,
      DioExceptionType.connectionError => S.current.errorNoInternet,
      _ => S.current.errorSomethingWentWrong,
    };
