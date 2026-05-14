import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/data/services/rest/rest_notification_service.dart';
import '../../../helpers/mocks.dart';

Response<T> _resp<T>(T data) => Response<T>(
      data: data,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    );

DioException _dioEx({int statusCode = 500}) => DioException(
      requestOptions: RequestOptions(path: ''),
      response: Response(
        data: null,
        statusCode: statusCode,
        requestOptions: RequestOptions(path: ''),
      ),
      type: DioExceptionType.badResponse,
    );

void main() {
  setUpAll(registerFallbackValues);

  late MockDio mockDio;
  late RestNotificationService service;

  setUp(() {
    mockDio = MockDio();
    service = RestNotificationService(mockDio);
  });

  group('registerDevice', () {
    test('posts token and platform to /api/v1/devices', () async {
      when(() => mockDio.post<dynamic>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => _resp<dynamic>(null));

      await service.registerDevice(token: 'fcm-token', platform: 'ANDROID');

      verify(() => mockDio.post<dynamic>(
            '/api/v1/devices',
            data: {'token': 'fcm-token', 'platform': 'ANDROID'},
          )).called(1);
    });

    test('works with iOS platform', () async {
      when(() => mockDio.post<dynamic>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => _resp<dynamic>(null));

      await service.registerDevice(token: 'apns-token', platform: 'IOS');

      verify(() => mockDio.post<dynamic>(
            '/api/v1/devices',
            data: {'token': 'apns-token', 'platform': 'IOS'},
          )).called(1);
    });

    test('propagates DioException on failure', () async {
      when(() => mockDio.post<dynamic>(
            any(),
            data: any(named: 'data'),
          )).thenThrow(_dioEx(statusCode: 400));

      expect(
        () => service.registerDevice(token: 'bad', platform: 'ANDROID'),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('deleteDevice', () {
    test('deletes /api/v1/devices/:token', () async {
      when(() => mockDio.delete<dynamic>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => _resp<dynamic>(null));

      await service.deleteDevice('fcm-token');

      verify(() => mockDio.delete<dynamic>(
            '/api/v1/devices/fcm-token',
            data: any(named: 'data'),
          )).called(1);
    });

    test('encodes token correctly in path', () async {
      when(() => mockDio.delete<dynamic>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => _resp<dynamic>(null));

      await service.deleteDevice('abc123xyz');

      verify(() => mockDio.delete<dynamic>(
            '/api/v1/devices/abc123xyz',
            data: any(named: 'data'),
          )).called(1);
    });

    test('propagates DioException on failure', () async {
      when(() => mockDio.delete<dynamic>(
            any(),
            data: any(named: 'data'),
          )).thenThrow(_dioEx(statusCode: 404));

      expect(
        () => service.deleteDevice('unknown-token'),
        throwsA(isA<DioException>()),
      );
    });
  });
}
