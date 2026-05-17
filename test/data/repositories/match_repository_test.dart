import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/repositories/match_repository.dart';
import 'package:tennis_cup/data/services/dto/match_dto.dart';
import '../../../test/helpers/mocks.dart';
import '../../../test/helpers/fixtures.dart';

void main() {
  setUpAll(registerFallbackValues);

  late MockIMatchService mockMatchService;
  late MockPlayerRepository mockPlayerRepository;
  late MatchRepository repository;

  setUp(() {
    mockMatchService = MockIMatchService();
    mockPlayerRepository = MockPlayerRepository();
    repository = MatchRepository(mockMatchService, mockPlayerRepository);
  });

  group('fetchMatchById', () {
    test('returns null when service returns null', () async {
      when(() => mockMatchService.fetchMatchById(any()))
          .thenAnswer((_) async => null);

      final result = await repository.fetchMatchById(matchId: '99');

      expect(result, isNull);
      verifyNever(() => mockPlayerRepository.fetchPlayerById(any()));
    });

    test('returns Match with correct data when service returns valid MatchDto',
        () async {
      final bluePlayer = aUser(id: 1, firstName: 'Blue', lastName: 'Player');
      final redPlayer = aUser(id: 2, firstName: 'Red', lastName: 'Player');
      final dto = aMatchDto(
        id: 42,
        bluePlayerId: 1,
        redPlayerId: 2,
        tournamentId: 10,
        scheduledStart: '2024-01-15T09:00:00',
        status: 'ACTIVE',
        sets: const [],
      );

      when(() => mockMatchService.fetchMatchById('42'))
          .thenAnswer((_) async => dto);
      when(() => mockPlayerRepository.fetchPlayerById(1))
          .thenAnswer((_) async => bluePlayer);
      when(() => mockPlayerRepository.fetchPlayerById(2))
          .thenAnswer((_) async => redPlayer);

      final result = await repository.fetchMatchById(matchId: '42');

      expect(result, isNotNull);
      expect(result!.id, 42);
      expect(result.bluePlayer, bluePlayer);
      expect(result.redPlayer, redPlayer);
      expect(result.tournamentId, 10);
      expect(result.scheduledStart, DateTime.parse('2024-01-15T09:00:00'));
    });

    test('returns null when a player fetch throws', () async {
      final dto = aMatchDto(bluePlayerId: 1, redPlayerId: 2);

      when(() => mockMatchService.fetchMatchById(any()))
          .thenAnswer((_) async => dto);
      when(() => mockPlayerRepository.fetchPlayerById(1))
          .thenThrow(Exception('not found'));
      when(() => mockPlayerRepository.fetchPlayerById(2))
          .thenAnswer((_) async => aUser(id: 2));

      // bluePlayer is missing from the map → _toMatch returns null
      final result = await repository.fetchMatchById(matchId: '1');

      expect(result, isNull);
    });

    test('calculates blueScore / redScore from set winners', () async {
      final bluePlayer = aUser(id: 1);
      final redPlayer = aUser(id: 2);
      final sets = [
        aMatchSetDto(number: 1, winnerId: 1), // blue wins
        aMatchSetDto(id: 2, number: 2, winnerId: 2), // red wins
        aMatchSetDto(id: 3, number: 3, winnerId: 1), // blue wins
      ];
      final dto = aMatchDto(bluePlayerId: 1, redPlayerId: 2, sets: sets);

      when(() => mockMatchService.fetchMatchById(any()))
          .thenAnswer((_) async => dto);
      when(() => mockPlayerRepository.fetchPlayerById(1))
          .thenAnswer((_) async => bluePlayer);
      when(() => mockPlayerRepository.fetchPlayerById(2))
          .thenAnswer((_) async => redPlayer);

      final result = await repository.fetchMatchById(matchId: '1');

      expect(result!.blueScore, 2);
      expect(result.redScore, 1);
    });

    test('isTechnicalDefeat is true when status == TECHNICAL_DEFEAT', () async {
      final dto = aMatchDto(
          bluePlayerId: 1, redPlayerId: 2, status: 'TECHNICAL_DEFEAT');

      when(() => mockMatchService.fetchMatchById(any()))
          .thenAnswer((_) async => dto);
      when(() => mockPlayerRepository.fetchPlayerById(1))
          .thenAnswer((_) async => aUser(id: 1));
      when(() => mockPlayerRepository.fetchPlayerById(2))
          .thenAnswer((_) async => aUser(id: 2));

      final result = await repository.fetchMatchById(matchId: '1');

      expect(result!.isTechnicalDefeat, isTrue);
    });

    test('isTechnicalDefeat is false when status is not TECHNICAL_DEFEAT',
        () async {
      final dto = aMatchDto(bluePlayerId: 1, redPlayerId: 2, status: 'ACTIVE');

      when(() => mockMatchService.fetchMatchById(any()))
          .thenAnswer((_) async => dto);
      when(() => mockPlayerRepository.fetchPlayerById(1))
          .thenAnswer((_) async => aUser(id: 1));
      when(() => mockPlayerRepository.fetchPlayerById(2))
          .thenAnswer((_) async => aUser(id: 2));

      final result = await repository.fetchMatchById(matchId: '1');

      expect(result!.isTechnicalDefeat, isFalse);
    });

    test('sets are sorted by number before computing scores', () async {
      final bluePlayer = aUser(id: 1);
      final redPlayer = aUser(id: 2);
      // Provide sets out of order
      final sets = [
        aMatchSetDto(id: 3, number: 3, bluePlayerScore: 7, redPlayerScore: 5),
        aMatchSetDto(id: 1, number: 1, bluePlayerScore: 3, redPlayerScore: 1),
        aMatchSetDto(id: 2, number: 2, bluePlayerScore: 0, redPlayerScore: 6),
      ];
      final dto = aMatchDto(bluePlayerId: 1, redPlayerId: 2, sets: sets);

      when(() => mockMatchService.fetchMatchById(any()))
          .thenAnswer((_) async => dto);
      when(() => mockPlayerRepository.fetchPlayerById(1))
          .thenAnswer((_) async => bluePlayer);
      when(() => mockPlayerRepository.fetchPlayerById(2))
          .thenAnswer((_) async => redPlayer);

      final result = await repository.fetchMatchById(matchId: '1');

      expect(result!.blueSetScores, [3, 0, 7]);
      expect(result.redSetScores, [1, 6, 5]);
    });
  });

  group('fetchHeadToHead', () {
    test('maps HeadToHeadMatchDto to Match and returns PageResult', () async {
      final player1 = aUser(id: 10);
      final player2 = aUser(id: 20);
      final h2hDto = aHeadToHeadMatchDto(
        matchId: 5,
        tournamentId: 7,
        player1SetsWon: 2,
        player2SetsWon: 1,
        matchDate: DateTime(2024, 3, 10),
      );
      final pageResult = PageResult(items: [h2hDto], hasMore: true);

      when(() => mockMatchService.fetchHeadToHead(
            userId1: 10,
            userId2: 20,
            page: any(named: 'page'),
          )).thenAnswer((_) async => pageResult);
      when(() => mockPlayerRepository.fetchPlayerById(10))
          .thenAnswer((_) async => player1);
      when(() => mockPlayerRepository.fetchPlayerById(20))
          .thenAnswer((_) async => player2);

      final result = await repository.fetchHeadToHead(
        playerId1: 10,
        playerId2: 20,
        page: const PageRequest(page: 0, size: 10),
      );

      expect(result.items, hasLength(1));
      expect(result.hasMore, isTrue);
      final match = result.items.first;
      expect(match.id, 5);
      expect(match.bluePlayer, player1);
      expect(match.redPlayer, player2);
      expect(match.blueScore, 2);
      expect(match.redScore, 1);
      expect(match.tournamentId, 7);
      expect(match.scheduledStart, DateTime(2024, 3, 10));
    });

    test('maps sets scores from HeadToHeadSetDto sorted by setNumber',
        () async {
      final player1 = aUser(id: 10);
      final player2 = aUser(id: 20);
      final sets = [
        const HeadToHeadSetDto(
            setNumber: 2,
            player1Score: 5,
            player2Score: 3,
            technicalDefeat: false),
        const HeadToHeadSetDto(
            setNumber: 1,
            player1Score: 7,
            player2Score: 4,
            technicalDefeat: false),
      ];
      final h2hDto = aHeadToHeadMatchDto(sets: sets, winnerId: 10);
      final pageResult = PageResult(items: [h2hDto], hasMore: false);

      when(() => mockMatchService.fetchHeadToHead(
            userId1: any(named: 'userId1'),
            userId2: any(named: 'userId2'),
            page: any(named: 'page'),
          )).thenAnswer((_) async => pageResult);
      when(() => mockPlayerRepository.fetchPlayerById(10))
          .thenAnswer((_) async => player1);
      when(() => mockPlayerRepository.fetchPlayerById(20))
          .thenAnswer((_) async => player2);

      final result = await repository.fetchHeadToHead(
        playerId1: 10,
        playerId2: 20,
        page: const PageRequest(page: 0, size: 10),
      );

      final match = result.items.first;
      expect(match.blueSetScores, [7, 5]); // sorted: set1 then set2
      expect(match.redSetScores, [4, 3]);
    });
  });

  group('fetchPlayersMatches', () {
    test('collects all player IDs and maps to Match list', () async {
      final bluePlayer = aUser(id: 1);
      final redPlayer = aUser(id: 2);
      final dto = aMatchDto(bluePlayerId: 1, redPlayerId: 2);
      final pageResult = PageResult(items: [dto], hasMore: false);

      when(() => mockMatchService.fetchPlayersMatches(
            playerId: any(named: 'playerId'),
            player2Id: any(named: 'player2Id'),
            page: any(named: 'page'),
          )).thenAnswer((_) async => pageResult);
      when(() => mockPlayerRepository.fetchPlayerById(1))
          .thenAnswer((_) async => bluePlayer);
      when(() => mockPlayerRepository.fetchPlayerById(2))
          .thenAnswer((_) async => redPlayer);

      final result = await repository.fetchPlayersMatches(
        player1Id: '1',
        page: const PageRequest(page: 0, size: 10),
      );

      expect(result.items, hasLength(1));
      expect(result.hasMore, isFalse);
      expect(result.items.first.bluePlayer, bluePlayer);
    });

    test('forwards player1Id, player2Id, and page to service', () async {
      final dto = aMatchDto(bluePlayerId: 1, redPlayerId: 2);
      final pageResult = PageResult(items: [dto], hasMore: false);

      when(() => mockMatchService.fetchPlayersMatches(
            playerId: '1',
            player2Id: '2',
            page: const PageRequest(page: 1, size: 5),
          )).thenAnswer((_) async => pageResult);
      when(() => mockPlayerRepository.fetchPlayerById(any())).thenAnswer(
          (inv) async => aUser(id: inv.positionalArguments.first as int));

      await repository.fetchPlayersMatches(
        player1Id: '1',
        player2Id: '2',
        page: const PageRequest(page: 1, size: 5),
      );

      verify(() => mockMatchService.fetchPlayersMatches(
            playerId: '1',
            player2Id: '2',
            page: const PageRequest(page: 1, size: 5),
          )).called(1);
    });
  });

  group('watchMatchChanges', () {
    test('emits Match when stream emits MatchDto with valid players', () async {
      final bluePlayer = aUser(id: 1);
      final redPlayer = aUser(id: 2);
      final dto = aMatchDto(bluePlayerId: 1, redPlayerId: 2);

      when(() => mockMatchService.watchMatchChanges('1'))
          .thenAnswer((_) => Stream.value(dto));
      when(() => mockPlayerRepository.fetchPlayerById(1))
          .thenAnswer((_) async => bluePlayer);
      when(() => mockPlayerRepository.fetchPlayerById(2))
          .thenAnswer((_) async => redPlayer);

      final stream = repository.watchMatchChanges('1');

      await expectLater(stream, emits(isA<Match>()));
    });

    test('filters out null matches when player fetch fails', () async {
      final dto = aMatchDto(bluePlayerId: 1, redPlayerId: 2);

      when(() => mockMatchService.watchMatchChanges('1'))
          .thenAnswer((_) => Stream.value(dto));
      // blue player fetch fails → _toMatch returns null → filtered
      when(() => mockPlayerRepository.fetchPlayerById(1))
          .thenThrow(Exception('service error'));
      when(() => mockPlayerRepository.fetchPlayerById(2))
          .thenAnswer((_) async => aUser(id: 2));

      final stream = repository.watchMatchChanges('1');

      await expectLater(stream, emitsDone);
    });
  });
}
