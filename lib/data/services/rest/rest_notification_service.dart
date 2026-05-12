import 'package:dio/dio.dart';
import 'package:tennis_cup/data/services/abstract/i_notification_service.dart';

class RestNotificationService implements INotificationService {
  final Dio _dio;

  RestNotificationService(this._dio);

  @override
  Future<void> registerDevice({
    required String token,
    required String platform,
  }) async {
    await _dio.post('/api/v1/devices', data: {
      'token': token,
      'platform': platform,
    });
  }

  @override
  Future<void> deleteDevice(String token) async {
    await _dio.delete('/api/v1/devices/$token');
  }
}
