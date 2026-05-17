import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/data/services/rest/rest_auth_service.dart';
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
  late MockAuthTokenStore mockTokenStore;
  late RestAuthService service;

  setUp(() {
    mockDio = MockDio();
    mockTokenStore = MockAuthTokenStore();
    service = RestAuthService(dio: mockDio, tokenStore: mockTokenStore);
  });

  group('login', () {
    const tokenJson = <String, dynamic>{
      'accessToken': 'at',
      'refreshToken': 'rt',
    };

    test('posts to /api/v1/auth/login and returns TokenResponse', () async {
      when(() => mockDio.post<dynamic>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => _resp<dynamic>(tokenJson));
      when(() => mockTokenStore.saveTokens(
            access: any(named: 'access'),
            refresh: any(named: 'refresh'),
          )).thenAnswer((_) async {});

      final result = await service.login(login: 'user', password: 'pass');

      expect(result.accessToken, 'at');
      expect(result.refreshToken, 'rt');
      verify(() => mockDio.post<dynamic>(
            '/api/v1/auth/login',
            data: {'login': 'user', 'password': 'pass'},
          )).called(1);
      verify(() => mockTokenStore.saveTokens(access: 'at', refresh: 'rt'))
          .called(1);
    });

    test('saves tokens to store on success', () async {
      when(() => mockDio.post<dynamic>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => _resp<dynamic>(tokenJson));
      when(() => mockTokenStore.saveTokens(
            access: any(named: 'access'),
            refresh: any(named: 'refresh'),
          )).thenAnswer((_) async {});

      await service.login(login: 'u', password: 'p');

      verify(() => mockTokenStore.saveTokens(access: 'at', refresh: 'rt'))
          .called(1);
    });

    test('propagates DioException on failure', () async {
      when(() => mockDio.post<dynamic>(
            any(),
            data: any(named: 'data'),
          )).thenThrow(_dioEx(statusCode: 401));

      expect(
        () => service.login(login: 'u', password: 'wrong'),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('register', () {
    test('posts required fields without optionals', () async {
      when(() => mockDio.post<dynamic>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => _resp<dynamic>(null));

      await service.register(
        login: 'u@test.com',
        password: 'pass',
        role: 'PLAYER',
        firstName: 'Ivan',
        lastName: 'Petrov',
      );

      verify(() => mockDio.post<dynamic>(
            '/api/v1/auth/register',
            data: {
              'login': 'u@test.com',
              'password': 'pass',
              'role': 'PLAYER',
              'firstName': 'Ivan',
              'lastName': 'Petrov',
            },
          )).called(1);
    });

    test('includes optional fields when provided', () async {
      when(() => mockDio.post<dynamic>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => _resp<dynamic>(null));

      await service.register(
        login: 'u@test.com',
        password: 'pass',
        role: 'PLAYER',
        firstName: 'Ivan',
        lastName: 'Petrov',
        patronymicName: 'Ivanovich',
        birthDate: '1990-01-01',
        gender: 'MALE',
        country: 'UA',
        city: 'Kyiv',
      );

      verify(() => mockDio.post<dynamic>(
            '/api/v1/auth/register',
            data: {
              'login': 'u@test.com',
              'password': 'pass',
              'role': 'PLAYER',
              'firstName': 'Ivan',
              'lastName': 'Petrov',
              'patronymicName': 'Ivanovich',
              'birthDate': '1990-01-01',
              'gender': 'MALE',
              'country': 'UA',
              'city': 'Kyiv',
            },
          )).called(1);
    });

    test('omits null optional fields from body', () async {
      final captured = <Map<String, dynamic>>[];
      when(() => mockDio.post<dynamic>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((invocation) async {
        captured.add(invocation.namedArguments[#data] as Map<String, dynamic>);
        return _resp<dynamic>(null);
      });

      await service.register(
        login: 'u',
        password: 'p',
        role: 'PLAYER',
        firstName: 'A',
        lastName: 'B',
        patronymicName: null,
        birthDate: null,
        gender: null,
      );

      expect(captured.single.containsKey('patronymicName'), isFalse);
      expect(captured.single.containsKey('birthDate'), isFalse);
      expect(captured.single.containsKey('gender'), isFalse);
    });
  });

  group('refreshAccessToken', () {
    test('throws Exception when no refresh token in store', () async {
      when(() => mockTokenStore.getRefreshToken())
          .thenAnswer((_) async => null);

      expect(
        () => service.refreshAccessToken(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('No refresh token'),
          ),
        ),
      );
    });

    test('posts to /api/v1/auth/refresh and returns access token', () async {
      when(() => mockTokenStore.getRefreshToken())
          .thenAnswer((_) async => 'rt-old');
      when(() => mockDio.post<dynamic>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => _resp<dynamic>(
            <String, dynamic>{'accessToken': 'at-new', 'refreshToken': 'rt-new'},
          ));
      when(() => mockTokenStore.saveTokens(
            access: any(named: 'access'),
            refresh: any(named: 'refresh'),
          )).thenAnswer((_) async {});

      final result = await service.refreshAccessToken();

      expect(result, 'at-new');
      verify(() => mockDio.post<dynamic>(
            '/api/v1/auth/refresh',
            data: {'refreshToken': 'rt-old'},
          )).called(1);
      verify(() =>
              mockTokenStore.saveTokens(access: 'at-new', refresh: 'rt-new'))
          .called(1);
    });
  });

  group('changePassword', () {
    test('throws Exception when not authenticated', () async {
      when(() => mockTokenStore.getAccessToken())
          .thenAnswer((_) async => null);

      expect(
        () => service.changePassword(
            currentPassword: 'old', newPassword: 'new'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Not authenticated'),
          ),
        ),
      );
    });

    test('posts with Authorization header when token present', () async {
      when(() => mockTokenStore.getAccessToken())
          .thenAnswer((_) async => 'my-token');
      when(() => mockDio.post<dynamic>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => _resp<dynamic>(null));

      await service.changePassword(
          currentPassword: 'old', newPassword: 'new');

      final captured = verify(
        () => mockDio.post<dynamic>(
          '/api/v1/auth/change-password',
          data: {'currentPassword': 'old', 'newPassword': 'new'},
          options: captureAny(named: 'options'),
        ),
      )..called(1);

      final opts = captured.captured.single as Options;
      expect(opts.headers?['Authorization'], 'Bearer my-token');
    });
  });

  group('logout', () {
    test('does nothing except clear tokens when no refresh token', () async {
      when(() => mockTokenStore.getRefreshToken())
          .thenAnswer((_) async => null);

      await service.logout();

      verifyNever(() => mockDio.post<dynamic>(any(),
          data: any(named: 'data')));
    });

    test('logout with no refresh token does not call clearAll', () async {
      when(() => mockTokenStore.getRefreshToken())
          .thenAnswer((_) async => null);

      await service.logout();

      verifyNever(() => mockTokenStore.clearAll());
    });

    test('posts to /api/v1/auth/logout and calls clearAll when token present',
        () async {
      when(() => mockTokenStore.getRefreshToken())
          .thenAnswer((_) async => 'rt');
      when(() => mockDio.post<dynamic>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => _resp<dynamic>(null));
      when(() => mockTokenStore.clearAll()).thenAnswer((_) async {});

      await service.logout();

      verify(() => mockDio.post<dynamic>(
            '/api/v1/auth/logout',
            data: {'refreshToken': 'rt'},
          )).called(1);
      verify(() => mockTokenStore.clearAll()).called(1);
    });

    test('calls clearAll in finally even when POST throws', () async {
      when(() => mockTokenStore.getRefreshToken())
          .thenAnswer((_) async => 'rt');
      when(() => mockDio.post<dynamic>(
            any(),
            data: any(named: 'data'),
          )).thenThrow(_dioEx());
      when(() => mockTokenStore.clearAll()).thenAnswer((_) async {});

      // try/finally re-throws — logout propagates the DioException after
      // clearAll runs.
      await expectLater(service.logout(), throwsA(isA<DioException>()));

      verify(() => mockTokenStore.clearAll()).called(1);
    });
  });
}
