import 'package:dio/dio.dart';

/// Extracts a user-friendly message from any caught exception.
/// Prioritises the backend's own error string, then maps HTTP status codes,
/// then network-level errors, falling back to a generic message.
String errorMessage(Object e) {
  if (e is DioException) return _fromDio(e);
  if (e is Exception) {
    final msg = e.toString().replaceFirst('Exception: ', '').trim();
    return msg.isNotEmpty ? msg : 'Something went wrong. Please try again.';
  }
  return 'Something went wrong. Please try again.';
}

String _fromDio(DioException e) {
  final data = e.response?.data;
  if (data is Map) {
    final raw = data['error'] ?? data['message'];
    if (raw is String && raw.isNotEmpty) return raw;
  }

  return switch (e.response?.statusCode) {
    400 => 'Invalid request. Please check your input.',
    401 => 'Session expired. Please log in again.',
    403 => 'You don\'t have permission to perform this action.',
    404 => 'The requested resource was not found.',
    409 => 'A conflict occurred — this resource may already exist.',
    422 => 'Invalid data provided. Please check your input.',
    500 => 'Server error. Please try again later.',
    503 => 'Service unavailable. Please try again later.',
    _ => _fromDioType(e),
  };
}

String _fromDioType(DioException e) => switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout =>
        'Connection timed out. Check your internet connection.',
      DioExceptionType.connectionError => 'No internet connection.',
      _ => 'Something went wrong. Please try again.',
    };
