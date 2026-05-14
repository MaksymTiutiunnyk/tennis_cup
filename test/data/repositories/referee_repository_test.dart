import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/data/repositories/referee_repository.dart';
import '../../../test/helpers/mocks.dart';
import '../../../test/helpers/fixtures.dart';

void main() {
  setUpAll(registerFallbackValues);

  late MockITournamentService mockTournamentService;
  late MockIMatchService mockMatchService;
  late MockIPlayerService mockPlayerService;
  late RefereeRepository repository;

  setUp(() {
    mockTournamentService = MockITournamentService();
    mockMatchService = MockIMatchService();
    mockPlayerService = MockIPlayerService();
    repository = RefereeRepository(
        mockTournamentService, mockMatchService, mockPlayerService);
  });

  group('fetchActiveTournamentsForReferee', () {
    test('calls service with page(0,100) and refereeId string, filters by refereeId',
        () async {
      final matching = aTournamentDto(id: 1, refereeId: 5);
      final nonMatching = aTournamentDto(id: 2, refereeId: 9);
      final pageResult =
          PageResult(items: [matching, nonMatching], hasMore: false);

      when(() => mockTournamentService.fetchActiveTournamentsForReferee(
            const PageRequest(page: 0, size: 100),
            '5',
          )).thenAnswer((_) async => pageResult);

      final result =
          await repository.fetchActiveTournamentsForReferee('5');

      expect(result, hasLength(1));
      expect(result.first.id, 1);
      verify(() => mockTournamentService.fetchActiveTournamentsForReferee(
            const PageRequest(page: 0, size: 100),
            '5',
          )).called(1);
    });

    test('invalid userId string → refereeId=-1 → all filtered out', () async {
      final dto = aTournamentDto(id: 1, refereeId: 5);
      final pageResult = PageResult(items: [dto], hasMore: false);

      when(() => mockTournamentService.fetchActiveTournamentsForReferee(
            const PageRequest(page: 0, size: 100),
            '-1',
          )).thenAnswer((_) async => pageResult);

      final result =
          await repository.fetchActiveTournamentsForReferee('not-a-number');

      expect(result, isEmpty);
    });

    test('returns only tournaments matching refereeId', () async {
      final t1 = aTournamentDto(id: 1, refereeId: 7);
      final t2 = aTournamentDto(id: 2, refereeId: 7);
      final t3 = aTournamentDto(id: 3, refereeId: 8);
      final pageResult = PageResult(items: [t1, t2, t3], hasMore: false);

      when(() => mockTournamentService.fetchActiveTournamentsForReferee(
            any(),
            '7',
          )).thenAnswer((_) async => pageResult);

      final result =
          await repository.fetchActiveTournamentsForReferee('7');

      expect(result, hasLength(2));
      expect(result.every((t) => t.refereeId == 7), isTrue);
    });
  });

  group('fetchMatchesForTournament', () {
    test('delegates to matchService.fetchTournamentMatches', () async {
      final matchDto = aMatchDto(id: 1);

      when(() => mockMatchService.fetchTournamentMatches('10'))
          .thenAnswer((_) async => [matchDto]);

      final result = await repository.fetchMatchesForTournament(10);

      expect(result, hasLength(1));
      expect(result.first.id, 1);
      verify(() => mockMatchService.fetchTournamentMatches('10')).called(1);
    });
  });

  group('fetchMatchWithPlayers', () {
    test('throws Exception when matchService returns null', () async {
      when(() => mockMatchService.fetchMatchById('99'))
          .thenAnswer((_) async => null);

      expect(
        () => repository.fetchMatchWithPlayers(99),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Match 99 not found'),
          ),
        ),
      );
    });

    test('fetches both players and returns record when match found', () async {
      final matchDto = aMatchDto(id: 5, bluePlayerId: 1, redPlayerId: 2);
      final bluePlayer = aPlayer(userId: 1, name: 'Blue');
      final redPlayer = aPlayer(userId: 2, name: 'Red');

      when(() => mockMatchService.fetchMatchById('5'))
          .thenAnswer((_) async => matchDto);
      when(() => mockPlayerService.fetchPlayerById(1))
          .thenAnswer((_) async => bluePlayer);
      when(() => mockPlayerService.fetchPlayerById(2))
          .thenAnswer((_) async => redPlayer);

      final result = await repository.fetchMatchWithPlayers(5);

      expect(result.match, matchDto);
      expect(result.blue, bluePlayer);
      expect(result.red, redPlayer);
    });
  });

  group('startMatch', () {
    test('delegates to matchService.startMatch', () async {
      final dto = aMatchDto(id: 1, status: 'ACTIVE');

      when(() => mockMatchService.startMatch(1, 42))
          .thenAnswer((_) async => dto);

      final result = await repository.startMatch(1, 42);

      expect(result.status, 'ACTIVE');
      verify(() => mockMatchService.startMatch(1, 42)).called(1);
    });
  });

  group('finishMatch', () {
    test('delegates to matchService.finishMatch', () async {
      final dto = aMatchDto(id: 1, status: 'FINISHED');

      when(() => mockMatchService.finishMatch(1))
          .thenAnswer((_) async => dto);

      final result = await repository.finishMatch(1);

      expect(result.status, 'FINISHED');
      verify(() => mockMatchService.finishMatch(1)).called(1);
    });
  });

  group('startSet', () {
    test('delegates to matchService.startSet', () async {
      final setDto = aMatchSetDto(id: 10, matchId: 1, number: 2);

      when(() => mockMatchService.startSet(1, 2))
          .thenAnswer((_) async => setDto);

      final result = await repository.startSet(1, 2);

      expect(result.number, 2);
      verify(() => mockMatchService.startSet(1, 2)).called(1);
    });
  });

  group('updateScore', () {
    test('delegates to matchService.updateScore', () async {
      final setDto = aMatchSetDto(bluePlayerScore: 3, redPlayerScore: 1);

      when(() => mockMatchService.updateScore(1, 1, 3, 1))
          .thenAnswer((_) async => setDto);

      final result = await repository.updateScore(1, 1, 3, 1);

      expect(result.bluePlayerScore, 3);
      expect(result.redPlayerScore, 1);
      verify(() => mockMatchService.updateScore(1, 1, 3, 1)).called(1);
    });
  });

  group('finishSet', () {
    test('delegates to matchService.finishSet', () async {
      final setDto = aMatchSetDto(status: 'FINISHED');

      when(() => mockMatchService.finishSet(1, 2))
          .thenAnswer((_) async => setDto);

      final result = await repository.finishSet(1, 2);

      expect(result.status, 'FINISHED');
      verify(() => mockMatchService.finishSet(1, 2)).called(1);
    });
  });

  group('technicalDefeatMatch', () {
    test('delegates to matchService.technicalDefeatMatch with reason', () async {
      final dto = aMatchDto(status: 'TECHNICAL_DEFEAT');

      when(() => mockMatchService.technicalDefeatMatch(1, 2, reason: 'Injury'))
          .thenAnswer((_) async => dto);

      final result =
          await repository.technicalDefeatMatch(1, 2, reason: 'Injury');

      expect(result.status, 'TECHNICAL_DEFEAT');
      verify(() =>
              mockMatchService.technicalDefeatMatch(1, 2, reason: 'Injury'))
          .called(1);
    });

    test('delegates without reason when reason is null', () async {
      final dto = aMatchDto(status: 'TECHNICAL_DEFEAT');

      when(() => mockMatchService.technicalDefeatMatch(1, 2, reason: null))
          .thenAnswer((_) async => dto);

      await repository.technicalDefeatMatch(1, 2);

      verify(() => mockMatchService.technicalDefeatMatch(1, 2, reason: null))
          .called(1);
    });
  });

  group('technicalDefeatSet', () {
    test('delegates to matchService.technicalDefeatSet', () async {
      final setDto = aMatchSetDto(status: 'FINISHED');

      when(() => mockMatchService.technicalDefeatSet(1, 3, 2, reason: 'TD'))
          .thenAnswer((_) async => setDto);

      final result =
          await repository.technicalDefeatSet(1, 3, 2, reason: 'TD');

      expect(result.status, 'FINISHED');
      verify(() =>
              mockMatchService.technicalDefeatSet(1, 3, 2, reason: 'TD'))
          .called(1);
    });
  });

  group('issueCard', () {
    test('delegates to matchService.issueCard', () async {
      final dto = aMatchDto(id: 1);

      when(() => mockMatchService.issueCard(1, 10, 'YELLOW'))
          .thenAnswer((_) async => dto);

      final result = await repository.issueCard(1, 10, 'YELLOW');

      expect(result.id, 1);
      verify(() => mockMatchService.issueCard(1, 10, 'YELLOW')).called(1);
    });

    test('delegates WHITE card correctly', () async {
      final dto = aMatchDto(id: 2);

      when(() => mockMatchService.issueCard(2, 5, 'WHITE'))
          .thenAnswer((_) async => dto);

      final result = await repository.issueCard(2, 5, 'WHITE');

      expect(result.id, 2);
      verify(() => mockMatchService.issueCard(2, 5, 'WHITE')).called(1);
    });
  });

  group('revokeCard', () {
    test('delegates to matchService.revokeCard', () async {
      final dto = aMatchDto(id: 1);

      when(() => mockMatchService.revokeCard(1, 55))
          .thenAnswer((_) async => dto);

      final result = await repository.revokeCard(1, 55);

      expect(result.id, 1);
      verify(() => mockMatchService.revokeCard(1, 55)).called(1);
    });
  });
}
