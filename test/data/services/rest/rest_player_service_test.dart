import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/data/models/player.dart';
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
};

final _searchResultJson = <String, dynamic>{
  'userId': 1,
  'firstName': 'Ivan',
  'lastName': 'Petrov',
  'avatarUrl': 'http://example.com/avatar.jpg',
};

final _ratingJson = <String, dynamic>{
  'userId': 1,
  'firstName': 'Ivan',
  'lastName': 'Petrov',
  'ratingValue': 1500.0,
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
    test('gets /api/v1/users/:id and parses profile JSON', () async {
      when(() => mockDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<dynamic>(_profileJson));

      final player = await service.fetchPlayerById(1);

      expect(player.userId, 1);
      expect(player.name, 'Ivan');
      expect(player.surname, 'Petrov');
      expect(player.city, 'Kyiv');
      expect(player.country, 'UA');
      expect(player.birthDate, '1990-05-15');
      expect(player.patronymicName, 'Ivanovich');
      expect(player.tournaments, 5);
      expect(player.matches, 10);
      expect(player.wins, 7);
      expect(player.loses, 3);
      expect(player.gold, 2);
      expect(player.silver, 1);
      expect(player.bronze, 0);
      expect(player.rankTennis, 1500.0);
      expect(player.imageUrl, 'http://example.com/avatar.jpg');
      expect(player.status, 'ACTIVE');
      verify(() => mockDio.get<dynamic>(
            '/api/v1/users/1',
            queryParameters: any(named: 'queryParameters'),
          )).called(1);
    });

    test('maps gender MALE to Sex.Men', () async {
      when(() => mockDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<dynamic>(_profileJson));

      final player = await service.fetchPlayerById(1);

      expect(player.sex, Sex.Men);
    });

    test('maps gender FEMALE to Sex.Women', () async {
      final femaleJson = Map<String, dynamic>.from(_profileJson)
        ..['gender'] = 'FEMALE';
      when(() => mockDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<dynamic>(femaleJson));

      final player = await service.fetchPlayerById(1);

      expect(player.sex, Sex.Women);
    });

    test('maps unknown/empty gender to Sex.All', () async {
      final noGenderJson = Map<String, dynamic>.from(_profileJson)
        ..['gender'] = '';
      when(() => mockDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<dynamic>(noGenderJson));

      final player = await service.fetchPlayerById(1);

      expect(player.sex, Sex.All);
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

      final players = await service.searchPlayersByName(query: 'Ivan');

      expect(players, hasLength(1));
      expect(players.first.userId, 1);
      expect(players.first.name, 'Ivan');
      expect(players.first.imageUrl, 'http://example.com/avatar.jpg');
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
        capturedParams.add(
            inv.namedArguments[#queryParameters] as Map<String, dynamic>?);
        return _resp<Map<String, dynamic>>({'content': <dynamic>[]});
      });

      await service.searchPlayersByName(query: 'Ivan');

      expect(capturedParams.single?.containsKey('gender'), isFalse);
    });

    test('search result has zeroed stats', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<Map<String, dynamic>>({
            'content': [_searchResultJson],
          }));

      final players = await service.searchPlayersByName(query: 'Ivan');

      final p = players.first;
      expect(p.matches, 0);
      expect(p.wins, 0);
      expect(p.loses, 0);
      expect(p.tournaments, 0);
    });
  });

  group('fetchRankingPlayers', () {
    test('gets /api/v1/ratings with page and sort params', () async {
      // fetchRankingPlayers calls fetchPlayerById for each rating record,
      // so we stub both endpoints.
      when(() => mockDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((inv) async {
        final path = inv.positionalArguments.first as String;
        if (path == '/api/v1/ratings') {
          return _resp<dynamic>(<String, dynamic>{
            'content': [_ratingJson],
            'totalPages': 1,
          });
        }
        return _resp<dynamic>(_profileJson);
      });

      final result = await service.fetchRankingPlayers(
        page: const PageRequest(page: 0, size: 10),
      );

      expect(result.items, hasLength(1));
      expect(result.hasMore, isFalse);
      // The enriched player should carry rankTennis from the rating record
      expect(result.items.first.rankTennis, 1500.0);
    });

    test('adds gender=MALE param when sexFilter is Sex.Men', () async {
      when(() => mockDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((inv) async {
        final path = inv.positionalArguments.first as String;
        if (path == '/api/v1/ratings') {
          return _resp<dynamic>(<String, dynamic>{
            'content': <dynamic>[],
            'totalPages': 1,
          });
        }
        return _resp<dynamic>(_profileJson);
      });

      await service.fetchRankingPlayers(
        page: const PageRequest(page: 0, size: 10),
        sexFilter: Sex.Men,
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

    test('adds gender=FEMALE param when sexFilter is Sex.Women', () async {
      when(() => mockDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((inv) async {
        final path = inv.positionalArguments.first as String;
        if (path == '/api/v1/ratings') {
          return _resp<dynamic>(<String, dynamic>{
            'content': <dynamic>[],
            'totalPages': 1,
          });
        }
        return _resp<dynamic>(_profileJson);
      });

      await service.fetchRankingPlayers(
        page: const PageRequest(page: 0, size: 10),
        sexFilter: Sex.Women,
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

    test('omits gender param when no sex filter', () async {
      final capturedParams = <Map<String, dynamic>?>[];
      when(() => mockDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((inv) async {
        final path = inv.positionalArguments.first as String;
        if (path == '/api/v1/ratings') {
          capturedParams.add(
              inv.namedArguments[#queryParameters] as Map<String, dynamic>?);
          return _resp<dynamic>(<String, dynamic>{
            'content': <dynamic>[],
            'totalPages': 1,
          });
        }
        return _resp<dynamic>(_profileJson);
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
