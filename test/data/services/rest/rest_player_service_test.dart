import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/data/models/gender.dart';
import 'package:tennis_cup/data/services/rest/rest_player_service.dart';

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

final _profileJson = <String, dynamic>{
  'id': 1,
  'firstName': 'Ivan',
  'lastName': 'Petrov',
  'gender': 'MALE',
  'city': 'Kyiv',
  'country': 'UA',
  'birthDate': '1990-05-15',
  'patronymicName': 'Ivanovich',
  'statistics': {
    'totalFinishedTournaments': 5,
    'totalMatches': 10,
    'wins': 7,
    'losses': 3,
    'firstPlaceCount': 2,
    'secondPlaceCount': 1,
    'thirdPlaceCount': 0,
  },
  'rating': 1500.0,
  'avatarUrl': 'http://example.com/avatar.jpg',
  'status': 'ACTIVE',
  'roles': ['PLAYER'],
};

final _searchResultJson = <String, dynamic>{
  'userId': 1,
  'firstName': 'Ivan',
  'lastName': 'Petrov',
  'avatarUrl': 'http://example.com/avatar.jpg',
  'roles': ['PLAYER'],
};

final _ratingJson = <String, dynamic>{
  'id': 100,
  'userId': 1,
  'firstName': 'Ivan',
  'lastName': 'Petrov',
  'ratingValue': 1500.0,
  'gender': 'MALE',
  'city': 'Kyiv',
  'country': 'UA',
  'birthDate': '1990-05-15',
  'avatarUrl': 'http://example.com/avatar.jpg',
};

final _briefJson = <String, dynamic>{
  'id': 1,
  'firstName': 'Ivan',
  'lastName': 'Petrov',
  'avatarUrl': 'http://example.com/avatar.jpg',
  'gender': 'MALE',
  'city': 'Kyiv',
  'country': 'UA',
  'birthDate': '1990-05-15',
};

void main() {
  setUpAll(registerFallbackValues);

  late MockDio mockDio;
  late RestPlayerService service;

  setUp(() {
    mockDio = MockDio();
    service = RestPlayerService(mockDio);
  });

  group('fetchPlayerById', () {
    test('gets /api/v1/users/:id and parses PlayerProfileDto', () async {
      when(() => mockDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<dynamic>(_profileJson));

      final dto = await service.fetchPlayerById(1);

      expect(dto.id, 1);
      expect(dto.firstName, 'Ivan');
      expect(dto.lastName, 'Petrov');
      expect(dto.city, 'Kyiv');
      expect(dto.country, 'UA');
      expect(dto.birthDate, '1990-05-15');
      expect(dto.patronymicName, 'Ivanovich');
      expect(dto.gender, 'MALE');
      expect(dto.rating, 1500.0);
      expect(dto.avatarUrl, 'http://example.com/avatar.jpg');
      expect(dto.status, 'ACTIVE');
      expect(dto.statistics, isNotNull);
      expect(dto.statistics!.totalFinishedTournaments, 5);
      expect(dto.statistics!.totalMatches, 10);
      expect(dto.statistics!.wins, 7);
      expect(dto.statistics!.losses, 3);
      expect(dto.statistics!.firstPlaceCount, 2);
      expect(dto.statistics!.secondPlaceCount, 1);
      expect(dto.statistics!.thirdPlaceCount, 0);
      verify(() => mockDio.get<dynamic>(
            '/api/v1/users/1',
            queryParameters: any(named: 'queryParameters'),
          )).called(1);
    });

    test('preserves gender FEMALE in DTO', () async {
      final femaleJson = Map<String, dynamic>.from(_profileJson)
        ..['gender'] = 'FEMALE';
      when(() => mockDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<dynamic>(femaleJson));

      final dto = await service.fetchPlayerById(1);

      expect(dto.gender, 'FEMALE');
    });

    test('propagates DioException on failure', () async {
      when(() => mockDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(_dioEx(statusCode: 404));

      expect(() => service.fetchPlayerById(999), throwsA(isA<DioException>()));
    });
  });

  group('searchPlayersByName', () {
    test('gets /api/v1/users/search with query, size, and roles params',
        () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<Map<String, dynamic>>({
            'content': [_searchResultJson],
          }));

      final dtos = await service.searchPlayersByName(query: 'Ivan');

      expect(dtos, hasLength(1));
      expect(dtos.first.userId, 1);
      expect(dtos.first.firstName, 'Ivan');
      expect(dtos.first.avatarUrl, 'http://example.com/avatar.jpg');
      verify(() => mockDio.get<Map<String, dynamic>>(
            '/api/v1/users/search',
            queryParameters: {
              'query': 'Ivan',
              'size': 20,
              'roles': ['PLAYER'],
            },
          )).called(1);
    });

    test('includes gender param when provided', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<Map<String, dynamic>>({
            'content': <dynamic>[],
          }));

      await service.searchPlayersByName(query: 'Ivan', gender: 'MALE');

      verify(() => mockDio.get<Map<String, dynamic>>(
            '/api/v1/users/search',
            queryParameters: {
              'query': 'Ivan',
              'size': 20,
              'roles': ['PLAYER'],
              'gender': 'MALE',
            },
          )).called(1);
    });

    test('omits gender param when null', () async {
      final capturedParams = <Map<String, dynamic>?>[];
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((inv) async {
        capturedParams
            .add(inv.namedArguments[#queryParameters] as Map<String, dynamic>?);
        return _resp<Map<String, dynamic>>({'content': <dynamic>[]});
      });

      await service.searchPlayersByName(query: 'Ivan');

      expect(capturedParams.single?.containsKey('gender'), isFalse);
    });
  });

  group('fetchRankingPlayers', () {
    test('gets /api/v1/ratings and parses RatingRecordDto items', () async {
      when(() => mockDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<dynamic>(<String, dynamic>{
            'content': [_ratingJson],
            'totalPages': 1,
          }));

      final result = await service.fetchRankingPlayers(
        page: const PageRequest(page: 0, size: 10),
      );

      expect(result.items, hasLength(1));
      expect(result.hasMore, isFalse);
      expect(result.items.first.userId, 1);
      expect(result.items.first.ratingValue, 1500.0);
      expect(result.items.first.gender, 'MALE');
      expect(result.items.first.avatarUrl, 'http://example.com/avatar.jpg');
    });

    test('adds gender=MALE param when genderFilter is Gender.male', () async {
      when(() => mockDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<dynamic>(<String, dynamic>{
            'content': <dynamic>[],
            'totalPages': 1,
          }));

      await service.fetchRankingPlayers(
        page: const PageRequest(page: 0, size: 10),
        genderFilter: Gender.male,
      );

      verify(() => mockDio.get<dynamic>(
            '/api/v1/ratings',
            queryParameters: {
              'page': 0,
              'size': 10,
              'sortBy': 'ratingValue',
              'sortDirection': 'DESC',
              'gender': 'MALE',
            },
          )).called(1);
    });

    test('adds gender=FEMALE param when genderFilter is Gender.female',
        () async {
      when(() => mockDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<dynamic>(<String, dynamic>{
            'content': <dynamic>[],
            'totalPages': 1,
          }));

      await service.fetchRankingPlayers(
        page: const PageRequest(page: 0, size: 10),
        genderFilter: Gender.female,
      );

      verify(() => mockDio.get<dynamic>(
            '/api/v1/ratings',
            queryParameters: {
              'page': 0,
              'size': 10,
              'sortBy': 'ratingValue',
              'sortDirection': 'DESC',
              'gender': 'FEMALE',
            },
          )).called(1);
    });

    test('omits gender param when no gender filter', () async {
      final capturedParams = <Map<String, dynamic>?>[];
      when(() => mockDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((inv) async {
        capturedParams.add(
            inv.namedArguments[#queryParameters] as Map<String, dynamic>?);
        return _resp<dynamic>(<String, dynamic>{
          'content': <dynamic>[],
          'totalPages': 1,
        });
      });

      await service.fetchRankingPlayers(
        page: const PageRequest(page: 0, size: 10),
      );

      expect(capturedParams.single?.containsKey('gender'), isFalse);
    });

    test('hasMore is true when more pages remain', () async {
      when(() => mockDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<dynamic>(<String, dynamic>{
            'content': <dynamic>[],
            'totalPages': 3,
          }));

      final result = await service.fetchRankingPlayers(
        page: const PageRequest(page: 0, size: 10),
      );

      expect(result.hasMore, isTrue);
    });
  });

  group('fetchUsersBatch', () {
    test('returns empty list and skips request when userIds is empty',
        () async {
      final result = await service.fetchUsersBatch(const []);

      expect(result, isEmpty);
      verifyNever(() => mockDio.post<List<dynamic>>(
            any(),
            data: any(named: 'data'),
          ));
    });

    test('posts /api/v1/users/batch with userIds body and parses UserBriefDto',
        () async {
      when(() => mockDio.post<List<dynamic>>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => _resp<List<dynamic>>([_briefJson]));

      final result = await service.fetchUsersBatch([1, 2, 3]);

      expect(result, hasLength(1));
      expect(result.first.id, 1);
      expect(result.first.firstName, 'Ivan');
      expect(result.first.avatarUrl, 'http://example.com/avatar.jpg');
      expect(result.first.gender, 'MALE');
      verify(() => mockDio.post<List<dynamic>>(
            '/api/v1/users/batch',
            data: {'userIds': [1, 2, 3]},
          )).called(1);
    });
  });

  group('updateProfile', () {
    test('patches /api/v1/admin/users/:id with provided fields', () async {
      when(() => mockDio.patch<void>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => _resp<void>(null));

      await service.updateProfile(1, {'firstName': 'Oleh', 'city': 'Lviv'});

      verify(() => mockDio.patch<void>(
            '/api/v1/admin/users/1',
            data: {'firstName': 'Oleh', 'city': 'Lviv'},
          )).called(1);
    });
  });
}
