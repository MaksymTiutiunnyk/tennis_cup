import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/data/services/rest/rest_tournament_service.dart';
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

final _tournamentJson = <String, dynamic>{
  'id': 1,
  'name': 'T1',
  'type': 'MORNING',
  'format': 'ROUND_ROBIN',
  'status': 'ACTIVE',
  'startTime': '2024-01-15T09:00:00',
  'arenaId': 1,
  'gender': 'MALE',
  'requiredPlayersCount': 4,
  'setsToWin': 2,
  'matchDurationMinutes': 30,
  'participants': <dynamic>[],
};

final _invitationJson = <String, dynamic>{
  'invitationId': 1,
  'tournamentId': 1,
  'tournamentName': 'T1',
  'startTime': '2024-01-15T09:00:00',
  'role': 'PLAYER',
  'status': 'PENDING',
  'createdAt': '2024-01-01T10:00:00',
};

final _arenaMatchViewJson = <String, dynamic>{
  'matchId': 1,
  'arena': {'id': 1, 'name': 'Arena 1'},
  'tournament': {
    'id': 1,
    'name': 'T1',
    'gender': 'MALE',
    'type': 'MORNING',
    'start': '2024-01-15T09:00:00',
  },
  'bluePlayer': {'id': 1, 'firstName': 'Ivan', 'lastName': 'Petrov'},
  'redPlayer': {'id': 2, 'firstName': 'Oleh', 'lastName': 'Koval'},
  'score': {'blueSets': 1, 'redSets': 0},
};

void main() {
  setUpAll(registerFallbackValues);

  late MockDio mockDio;
  late RestTournamentService service;

  setUp(() {
    mockDio = MockDio();
    service = RestTournamentService(mockDio);
  });

  group('fetchTournamentById', () {
    test('gets /api/v1/tournaments/:id and parses TournamentDto', () async {
      when(() => mockDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<dynamic>(_tournamentJson));

      final result = await service.fetchTournamentById('1');

      expect(result.id, 1);
      expect(result.name, 'T1');
      expect(result.status, 'ACTIVE');
      expect(result.format, 'ROUND_ROBIN');
      verify(() => mockDio.get<dynamic>(
            '/api/v1/tournaments/1',
            queryParameters: any(named: 'queryParameters'),
          )).called(1);
    });

    test('propagates DioException on failure', () async {
      when(() => mockDio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(_dioEx(statusCode: 404));

      expect(
        () => service.fetchTournamentById('99'),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('fetchCurrentMatches', () {
    test('gets /api/v1/dashboard/arenas/current-matches and returns list',
        () async {
      when(() => mockDio.get<List<dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<List<dynamic>>([_arenaMatchViewJson]));

      final result = await service.fetchCurrentMatches();

      expect(result, hasLength(1));
      expect(result.first.matchId, 1);
      verify(() => mockDio.get<List<dynamic>>(
            '/api/v1/dashboard/arenas/current-matches',
            queryParameters: any(named: 'queryParameters'),
          )).called(1);
    });

    test('returns empty list when response data is empty', () async {
      when(() => mockDio.get<List<dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<List<dynamic>>([]));

      final result = await service.fetchCurrentMatches();

      expect(result, isEmpty);
    });
  });

  group('fetchInvitations', () {
    test('gets /api/v1/tournaments/my-invitations with status param', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<Map<String, dynamic>>({
            'content': [_invitationJson],
          }));

      final result = await service.fetchInvitations(status: 'PENDING');

      expect(result, hasLength(1));
      expect(result.first.invitationId, 1);
      expect(result.first.tournamentName, 'T1');
      expect(result.first.role, 'PLAYER');
      expect(result.first.status, 'PENDING');
      verify(() => mockDio.get<Map<String, dynamic>>(
            '/api/v1/tournaments/my-invitations',
            queryParameters: {'status': 'PENDING'},
          )).called(1);
    });

    test('returns empty list when content is null', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<Map<String, dynamic>>({
            'content': null,
          }));

      final result = await service.fetchInvitations(status: 'ACCEPTED');

      expect(result, isEmpty);
    });
  });

  group('acceptInvitation', () {
    test('posts to /api/v1/tournaments/invitations/:id/accept', () async {
      when(() => mockDio.post<void>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => _resp<void>(null));

      await service.acceptInvitation('42');

      verify(() => mockDio.post<void>(
            '/api/v1/tournaments/invitations/42/accept',
            data: any(named: 'data'),
          )).called(1);
    });

    test('propagates DioException on failure', () async {
      when(() => mockDio.post<void>(
            any(),
            data: any(named: 'data'),
          )).thenThrow(_dioEx(statusCode: 404));

      expect(
        () => service.acceptInvitation('99'),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('declineInvitation', () {
    test('posts to /api/v1/tournaments/invitations/:id/decline', () async {
      when(() => mockDio.post<void>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => _resp<void>(null));

      await service.declineInvitation('42');

      verify(() => mockDio.post<void>(
            '/api/v1/tournaments/invitations/42/decline',
            data: any(named: 'data'),
          )).called(1);
    });
  });

  group('deleteTournament', () {
    test('deletes /api/v1/tournaments/:id', () async {
      when(() => mockDio.delete<void>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => _resp<void>(null));

      await service.deleteTournament(1);

      verify(() => mockDio.delete<void>(
            '/api/v1/tournaments/1',
            data: any(named: 'data'),
          )).called(1);
    });

    test('propagates DioException on failure', () async {
      when(() => mockDio.delete<void>(
            any(),
            data: any(named: 'data'),
          )).thenThrow(_dioEx(statusCode: 403));

      expect(() => service.deleteTournament(1), throwsA(isA<DioException>()));
    });
  });

  group('fetchRefereeTournaments', () {
    test('gets /api/v1/tournaments with refereeId and given statuses',
        () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<Map<String, dynamic>>({
            'content': [_tournamentJson],
            'totalPages': 1,
          }));

      final result = await service.fetchRefereeTournaments(
        page: const PageRequest(page: 0, size: 10),
        refereeId: 'ref-5',
        statuses: const ['PENDING', 'ACTIVE'],
      );

      expect(result.items, hasLength(1));
      expect(result.items.first.id, 1);
      expect(result.hasMore, isFalse);
      verify(() => mockDio.get<Map<String, dynamic>>(
            '/api/v1/tournaments',
            queryParameters: {
              'page': 0,
              'size': 10,
              'refereeId': 'ref-5',
              'statuses': ['PENDING', 'ACTIVE'],
            },
          )).called(1);
    });

    test('hasMore is true when more pages remain', () async {
      when(() => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => _resp<Map<String, dynamic>>({
            'content': [_tournamentJson],
            'totalPages': 3,
          }));

      final result = await service.fetchRefereeTournaments(
        page: const PageRequest(page: 0, size: 10),
        refereeId: 'ref-5',
        statuses: const ['ACTIVE'],
      );

      expect(result.hasMore, isTrue);
    });
  });
}
