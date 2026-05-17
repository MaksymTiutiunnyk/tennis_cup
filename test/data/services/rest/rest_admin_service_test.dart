import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/data/services/dto/admin_dto.dart';
import 'package:tennis_cup/data/services/rest/rest_admin_service.dart';
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

final _pendingUserJson = <String, dynamic>{
  'id': 1,
  'login': 'u@test.com',
  'status': 'PENDING_APPROVAL',
  'roles': ['PLAYER'],
  'createdAt': '2024-01-01T10:00:00',
};

final _userSearchJson = <String, dynamic>{
  'userId': 1,
  'firstName': 'Ivan',
  'lastName': 'Petrov',
  'roles': ['PLAYER'],
};

final _userProfileJson = <String, dynamic>{
  'id': 1,
  'firstName': 'Ivan',
  'lastName': 'Petrov',
  'roles': ['PLAYER'],
};

void main() {
  setUpAll(registerFallbackValues);

  late MockDio mockDio;
  late RestAdminService service;

  setUp(() {
    mockDio = MockDio();
    service = RestAdminService(mockDio);
  });

  group('fetchPendingUsers', () {
    test('gets /api/v1/admin/users/pending with page and size params', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<Map<String, dynamic>>({
            'content': [_pendingUserJson],
            'totalPages': 1,
          }));

      final result = await service.fetchPendingUsers(
        const PageRequest(page: 0, size: 10),
      );

      expect(result.items, hasLength(1));
      expect(result.items.first.id, 1);
      expect(result.items.first.login, 'u@test.com');
      expect(result.items.first.status, 'PENDING_APPROVAL');
      expect(result.hasMore, isFalse);
      verify(() => mockDio.get<Map<String, dynamic>>(
            '/api/v1/admin/users/pending',
            queryParameters: {'page': 0, 'size': 10},
          )).called(1);
    });

    test('hasMore is true when more pages remain', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<Map<String, dynamic>>({
            'content': [_pendingUserJson],
            'totalPages': 3,
          }));

      final result = await service.fetchPendingUsers(
        const PageRequest(page: 0, size: 10),
      );

      expect(result.hasMore, isTrue);
    });
  });

  group('approveUser', () {
    test('posts to /api/v1/admin/users/:userId/approve', () async {
      when(() => mockDio.post<void>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => _resp<void>(null));

      await service.approveUser(1);

      verify(() => mockDio.post<void>(
            '/api/v1/admin/users/1/approve',
            data: any(named: 'data'),
          )).called(1);
    });

    test('propagates DioException on failure', () async {
      when(() => mockDio.post<void>(
            any(),
            data: any(named: 'data'),
          )).thenThrow(_dioEx(statusCode: 404));

      expect(() => service.approveUser(999), throwsA(isA<DioException>()));
    });
  });

  group('rejectUser', () {
    test('posts to /api/v1/admin/users/:userId/reject with reason', () async {
      final captured = <dynamic>[];
      when(() => mockDio.post<void>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((inv) async {
        captured.add(inv.namedArguments[#data]);
        return _resp<void>(null);
      });

      await service.rejectUser(1, reason: 'Duplicate account');

      verify(() => mockDio.post<void>(
            '/api/v1/admin/users/1/reject',
            data: any(named: 'data'),
          )).called(1);
      expect((captured.single as Map<String, dynamic>)['reason'],
          'Duplicate account');
    });

    test('posts empty map when reason is null', () async {
      final captured = <dynamic>[];
      when(() => mockDio.post<void>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((inv) async {
        captured.add(inv.namedArguments[#data]);
        return _resp<void>(null);
      });

      await service.rejectUser(1);

      expect(captured.single, isA<Map<String, dynamic>>());
      expect((captured.single as Map<String, dynamic>).isEmpty, isTrue);
    });
  });

  group('createUser', () {
    test('posts dto.toJson() to /api/v1/admin/users', () async {
      const dto = CreateUserRequestDto(
        role: 'PLAYER',
        login: 'new@test.com',
        password: 'secret',
        firstName: 'Anna',
        lastName: 'Koval',
      );

      when(() => mockDio.post<void>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => _resp<void>(null));

      await service.createUser(dto);

      verify(() => mockDio.post<void>(
            '/api/v1/admin/users',
            data: dto.toJson(),
          )).called(1);
    });
  });

  group('searchUsers', () {
    test('gets /api/v1/users/search with query and size params', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<Map<String, dynamic>>({
            'content': [_userSearchJson],
          }));

      final result = await service.searchUsers(query: 'Ivan');

      expect(result, hasLength(1));
      expect(result.first.userId, 1);
      expect(result.first.firstName, 'Ivan');
      verify(() => mockDio.get<Map<String, dynamic>>(
            '/api/v1/users/search',
            queryParameters: {'query': 'Ivan', 'size': 20},
          )).called(1);
    });

    test('includes roles param when roles list is non-empty', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<Map<String, dynamic>>({
            'content': <dynamic>[],
          }));

      await service.searchUsers(query: 'Ivan', roles: ['REFEREE']);

      verify(() => mockDio.get<Map<String, dynamic>>(
            '/api/v1/users/search',
            queryParameters: {
              'query': 'Ivan',
              'size': 20,
              'roles': ['REFEREE'],
            },
          )).called(1);
    });

    test('omits roles param when roles is null', () async {
      final capturedParams = <Map<String, dynamic>?>[];
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((inv) async {
        capturedParams.add(
            inv.namedArguments[#queryParameters] as Map<String, dynamic>?);
        return _resp<Map<String, dynamic>>({'content': <dynamic>[]});
      });

      await service.searchUsers(query: 'Ivan');

      expect(capturedParams.single?.containsKey('roles'), isFalse);
    });

    test('omits roles param when roles is empty list', () async {
      final capturedParams = <Map<String, dynamic>?>[];
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((inv) async {
        capturedParams.add(
            inv.namedArguments[#queryParameters] as Map<String, dynamic>?);
        return _resp<Map<String, dynamic>>({'content': <dynamic>[]});
      });

      await service.searchUsers(query: 'Ivan', roles: []);

      expect(capturedParams.single?.containsKey('roles'), isFalse);
    });
  });

  group('getUserById', () {
    test('gets /api/v1/users/:userId and returns UserProfileDto', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<Map<String, dynamic>>(_userProfileJson));

      final result = await service.getUserById(1);

      expect(result.userId, 1);
      expect(result.firstName, 'Ivan');
      expect(result.lastName, 'Petrov');
      expect(result.roles, ['PLAYER']);
      verify(() => mockDio.get<Map<String, dynamic>>(
            '/api/v1/users/1',
            queryParameters: any(named: 'queryParameters'),
          )).called(1);
    });

    test('propagates DioException on failure', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(_dioEx(statusCode: 404));

      expect(() => service.getUserById(999), throwsA(isA<DioException>()));
    });
  });
}
