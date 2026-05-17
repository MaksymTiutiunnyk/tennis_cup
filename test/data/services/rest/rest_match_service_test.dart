import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/data/services/dto/match_dto.dart';
import 'package:tennis_cup/data/services/rest/rest_match_service.dart';

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

final _matchJson = <String, dynamic>{
  'id': 1,
  'tournamentId': 10,
  'refereeId': 5,
  'status': 'ACTIVE',
  'bluePlayerId': 1,
  'redPlayerId': 2,
  'setsToWin': 2,
  'scheduledStart': '2024-01-15T09:00:00',
  'scheduledEnd': '2024-01-15T11:00:00',
  'sets': <dynamic>[],
  'cards': <dynamic>[],
};

final _setJson = <String, dynamic>{
  'id': 1,
  'matchId': 1,
  'number': 1,
  'bluePlayerScore': 3,
  'redPlayerScore': 2,
  'status': 'FINISHED',
  'winnerId': 1,
};

void main() {
  setUpAll(registerFallbackValues);

  late MockDio mockDio;
  late MockMatchWebSocketService mockWs;
  late RestMatchService service;

  setUp(() {
    mockDio = MockDio();
    mockWs = MockMatchWebSocketService();
    service = RestMatchService(mockDio, mockWs);
  });

  group('fetchMatchById', () {
    test('returns MatchDto on success', () async {
      when(() => mockDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<dynamic>(_matchJson));

      final result = await service.fetchMatchById('1');

      expect(result, isNotNull);
      expect(result!.id, 1);
      expect(result.status, 'ACTIVE');
      verify(() => mockDio.get<dynamic>('/api/v1/matches/1',
          queryParameters: any(named: 'queryParameters'))).called(1);
    });

    test('returns null on 404', () async {
      when(() => mockDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(_dioEx(statusCode: 404));

      final result = await service.fetchMatchById('99');

      expect(result, isNull);
    });

    test('rethrows non-404 DioException', () async {
      when(() => mockDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(_dioEx(statusCode: 500));

      expect(
        () => service.fetchMatchById('1'),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('fetchTournamentMatches', () {
    test('gets /api/v1/matches with tournamentId and size params', () async {
      when(() => mockDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<dynamic>(<String, dynamic>{
            'content': [_matchJson],
          }));

      final result = await service.fetchTournamentMatches('10');

      expect(result, hasLength(1));
      expect(result.first.id, 1);
      verify(() => mockDio.get<dynamic>(
            '/api/v1/matches',
            queryParameters: {'tournamentId': '10', 'size': 100},
          )).called(1);
    });

    test('returns empty list when content is empty', () async {
      when(() => mockDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<dynamic>(<String, dynamic>{
            'content': <dynamic>[],
          }));

      final result = await service.fetchTournamentMatches('10');

      expect(result, isEmpty);
    });
  });

  group('fetchHeadToHead', () {
    final h2hJson = <String, dynamic>{
      'matchId': 1,
      'tournamentId': 1,
      'matchDate': '2024-01-15T10:00:00',
      'player1SetsWon': 2,
      'player2SetsWon': 1,
      'technicalDefeat': false,
      'sets': <dynamic>[],
    };

    test('gets /api/v1/matches/head-to-head with correct params', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<Map<String, dynamic>>({
            'content': [h2hJson],
            'totalPages': 1,
          }));

      final result = await service.fetchHeadToHead(
        userId1: 1,
        userId2: 2,
        page: const PageRequest(page: 0, size: 10),
      );

      expect(result.items, hasLength(1));
      expect(result.hasMore, isFalse);
      verify(() => mockDio.get<Map<String, dynamic>>(
            '/api/v1/matches/head-to-head',
            queryParameters: {
              'player1Id': 1,
              'player2Id': 2,
              'page': 0,
              'size': 10,
            },
          )).called(1);
    });

    test('hasMore is true when more pages remain', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<Map<String, dynamic>>({
            'content': [h2hJson],
            'totalPages': 3,
          }));

      final result = await service.fetchHeadToHead(
        userId1: 1,
        userId2: 2,
        page: const PageRequest(page: 0, size: 10),
      );

      expect(result.hasMore, isTrue);
    });
  });

  group('startMatch', () {
    test('posts to /api/v1/matches/:id/start with firstServerId', () async {
      when(() => mockDio.post<dynamic>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => _resp<dynamic>(_matchJson));

      final result = await service.startMatch(1, 42);

      expect(result.id, 1);
      verify(() => mockDio.post<dynamic>(
            '/api/v1/matches/1/start',
            data: {'firstServerId': 42},
          )).called(1);
    });
  });

  group('finishMatch', () {
    test('posts to /api/v1/matches/:id/finish', () async {
      when(() => mockDio.post<dynamic>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => _resp<dynamic>(_matchJson));

      final result = await service.finishMatch(1);

      expect(result.id, 1);
      verify(() => mockDio.post<dynamic>(
            '/api/v1/matches/1/finish',
            data: any(named: 'data'),
          )).called(1);
    });
  });

  group('startSet', () {
    test('posts to /api/v1/matches/:matchId/sets/:setNumber/start', () async {
      when(() => mockDio.post<dynamic>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => _resp<dynamic>(_setJson));

      final result = await service.startSet(1, 2);

      expect(result.id, 1);
      expect(result.number, 1);
      verify(() => mockDio.post<dynamic>(
            '/api/v1/matches/1/sets/2/start',
            data: any(named: 'data'),
          )).called(1);
    });
  });

  group('updateScore', () {
    test('patches score with correct body', () async {
      when(() => mockDio.patch<dynamic>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => _resp<dynamic>(_setJson));

      final result = await service.updateScore(1, 1, 3, 2);

      expect(result.bluePlayerScore, 3);
      expect(result.redPlayerScore, 2);
      verify(() => mockDio.patch<dynamic>(
            '/api/v1/matches/1/sets/1/score',
            data: {'bluePlayerScore': 3, 'redPlayerScore': 2},
          )).called(1);
    });
  });

  group('finishSet', () {
    test('posts to /api/v1/matches/:matchId/sets/:setNumber/finish', () async {
      when(() => mockDio.post<dynamic>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => _resp<dynamic>(_setJson));

      final result = await service.finishSet(1, 1);

      expect(result.status, 'FINISHED');
      verify(() => mockDio.post<dynamic>(
            '/api/v1/matches/1/sets/1/finish',
            data: any(named: 'data'),
          )).called(1);
    });
  });

  group('technicalDefeatMatch', () {
    test('posts without reason when reason is null', () async {
      final captured = <Map<String, dynamic>>[];
      when(() => mockDio.post<dynamic>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((inv) async {
        captured.add(inv.namedArguments[#data] as Map<String, dynamic>);
        return _resp<dynamic>(_matchJson);
      });

      await service.technicalDefeatMatch(1, 2);

      expect(captured.single.containsKey('reason'), isFalse);
      expect(captured.single['loserId'], 2);
      verify(() => mockDio.post<dynamic>(
            '/api/v1/matches/1/technical-defeat',
            data: any(named: 'data'),
          )).called(1);
    });

    test('posts with reason when reason is provided', () async {
      final captured = <Map<String, dynamic>>[];
      when(() => mockDio.post<dynamic>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((inv) async {
        captured.add(inv.namedArguments[#data] as Map<String, dynamic>);
        return _resp<dynamic>(_matchJson);
      });

      await service.technicalDefeatMatch(1, 2, reason: 'Medical');

      expect(captured.single['reason'], 'Medical');
    });
  });

  group('issueCard', () {
    test('posts card to /api/v1/matches/:matchId/cards', () async {
      when(() => mockDio.post<dynamic>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => _resp<dynamic>(_matchJson));

      final result = await service.issueCard(1, 10, 'YELLOW');

      expect(result.id, 1);
      verify(() => mockDio.post<dynamic>(
            '/api/v1/matches/1/cards',
            data: {'playerId': 10, 'cardType': 'YELLOW'},
          )).called(1);
    });
  });

  group('revokeCard', () {
    test('deletes /api/v1/matches/:matchId/cards/:cardId', () async {
      when(() => mockDio.delete<dynamic>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => _resp<dynamic>(_matchJson));

      final result = await service.revokeCard(1, 5);

      expect(result.id, 1);
      verify(() => mockDio.delete<dynamic>(
            '/api/v1/matches/1/cards/5',
            data: any(named: 'data'),
          )).called(1);
    });
  });

  group('fetchPlayersMatches', () {
    test('gets /api/v1/matches with playerId and page params', () async {
      when(() => mockDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<dynamic>(<String, dynamic>{
            'content': [_matchJson],
            'totalPages': 1,
          }));

      final result = await service.fetchPlayersMatches(
        playerId: '1',
        page: const PageRequest(page: 0, size: 10),
      );

      expect(result.items, hasLength(1));
      verify(() => mockDio.get<dynamic>(
            '/api/v1/matches',
            queryParameters: {'playerId': '1', 'page': 0, 'size': 10},
          )).called(1);
    });

    test('filters by player2Id client-side', () async {
      final match1 = Map<String, dynamic>.from(_matchJson)
        ..['bluePlayerId'] = 1
        ..['redPlayerId'] = 2;
      final match2 = Map<String, dynamic>.from(_matchJson)
        ..['id'] = 2
        ..['bluePlayerId'] = 1
        ..['redPlayerId'] = 3;

      when(() => mockDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<dynamic>(<String, dynamic>{
            'content': [match1, match2],
            'totalPages': 1,
          }));

      final result = await service.fetchPlayersMatches(
        playerId: '1',
        player2Id: '2',
        page: const PageRequest(page: 0, size: 10),
      );

      expect(result.items, hasLength(1));
      expect(result.items.first.redPlayerId, 2);
    });

    test('hasMore is true when more pages remain', () async {
      when(() => mockDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<dynamic>(<String, dynamic>{
            'content': [_matchJson],
            'totalPages': 3,
          }));

      final result = await service.fetchPlayersMatches(
        playerId: '1',
        page: const PageRequest(page: 0, size: 10),
      );

      expect(result.hasMore, isTrue);
    });
  });

  group('watchMatchChanges', () {
    test('delegates to MatchWebSocketService.watchMatch', () {
      const stream = Stream<MatchDto>.empty();
      when(() => mockWs.watchMatch('42')).thenAnswer((_) => stream);

      final result = service.watchMatchChanges('42');

      expect(result, stream);
      verify(() => mockWs.watchMatch('42')).called(1);
    });
  });
}
