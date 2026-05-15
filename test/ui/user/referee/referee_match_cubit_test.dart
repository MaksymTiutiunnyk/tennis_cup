import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/ui/user/referee/view_models/referee_match_cubit.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  setUpAll(registerFallbackValues);

  late MockMatchRepository mockRepo;

  final bluePlayer = aUser(id: 1, firstName: 'Blue');
  final redPlayer = aUser(id: 2, firstName: 'Red');
  final baseMatch = aMatch(id: 10, bluePlayer: bluePlayer, redPlayer: redPlayer);

  setUp(() {
    mockRepo = MockMatchRepository();
  });

  RefereeMatchCubit buildCubit() => RefereeMatchCubit(repository: mockRepo);

  // Helper: stub fetchMatchWithPlayers to return a ready Match
  void stubFetchMatch(Match match) {
    when(() => mockRepo.fetchMatchWithPlayers(match.id))
        .thenAnswer((_) async => match);
  }

  group('load', () {
    blocTest<RefereeMatchCubit, RefereeMatchState>(
      'success emits [RefereeMatchLoading, RefereeMatchReady]',
      setUp: () => stubFetchMatch(baseMatch),
      build: buildCubit,
      act: (cubit) => cubit.load(10),
      expect: () => [
        isA<RefereeMatchLoading>(),
        isA<RefereeMatchReady>()
            .having((s) => s.match.id, 'match.id', 10)
            .having((s) => s.bluePlayer, 'bluePlayer', bluePlayer)
            .having((s) => s.redPlayer, 'redPlayer', redPlayer),
      ],
    );

    blocTest<RefereeMatchCubit, RefereeMatchState>(
      'failure emits [RefereeMatchLoading, RefereeMatchError]',
      setUp: () {
        when(() => mockRepo.fetchMatchWithPlayers(any()))
            .thenThrow(Exception('not found'));
      },
      build: buildCubit,
      act: (cubit) => cubit.load(10),
      expect: () => [
        isA<RefereeMatchLoading>(),
        isA<RefereeMatchError>()
            .having((s) => s.message, 'message', isNotEmpty),
      ],
    );
  });

  group('setFirstServer', () {
    blocTest<RefereeMatchCubit, RefereeMatchState>(
      'when state is Ready emits Ready with firstServerPlayerId set',
      setUp: () => stubFetchMatch(baseMatch),
      build: buildCubit,
      act: (cubit) async {
        await cubit.load(10);
        cubit.setFirstServer(1);
      },
      skip: 2, // skip Loading + Ready from load
      expect: () => [
        isA<RefereeMatchReady>()
            .having((s) => s.firstServerPlayerId, 'firstServerPlayerId', 1),
      ],
    );

    blocTest<RefereeMatchCubit, RefereeMatchState>(
      'when state is NOT Ready no state change',
      build: buildCubit,
      act: (cubit) => cubit.setFirstServer(1),
      expect: () => const [],
    );
  });

  group('startMatch', () {
    blocTest<RefereeMatchCubit, RefereeMatchState>(
      'without firstServerPlayerId emits Ready with notification, no API calls',
      setUp: () => stubFetchMatch(baseMatch),
      build: buildCubit,
      act: (cubit) async {
        await cubit.load(10);
        await cubit.startMatch();
      },
      skip: 2,
      expect: () => [
        isA<RefereeMatchReady>()
            .having((s) => s.notification, 'notification', isNotEmpty),
      ],
      verify: (_) {
        verifyNever(() => mockRepo.startMatch(any(), any()));
      },
    );

    blocTest<RefereeMatchCubit, RefereeMatchState>(
      'with firstServerPlayerId calls startMatch, startSet, then reloads',
      setUp: () {
        final pendingSet = aMatchSet(
            id: 1, matchId: 10, number: 1, status: SetStatus.pending);
        final startedMatch = aMatch(
          id: 10,
          bluePlayer: bluePlayer,
          redPlayer: redPlayer,
          firstServerId: 1,
          sets: [pendingSet],
        );
        final reloadedMatch = aMatch(
          id: 10,
          bluePlayer: bluePlayer,
          redPlayer: redPlayer,
          firstServerId: 1,
        );

        var callCount = 0;
        when(() => mockRepo.fetchMatchWithPlayers(10)).thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? baseMatch : reloadedMatch;
        });
        when(() => mockRepo.startMatch(10, 1))
            .thenAnswer((_) async => startedMatch);
        when(() => mockRepo.startSet(10, 1)).thenAnswer((_) async {});
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.load(10);
        cubit.setFirstServer(1);
        await cubit.startMatch();
      },
      skip: 2, // load: Loading + Ready
      expect: () => [
        isA<RefereeMatchReady>()
            .having((s) => s.firstServerPlayerId, 'firstServerPlayerId', 1),
        isA<RefereeMatchReady>(), // after reload
      ],
      verify: (_) {
        verify(() => mockRepo.startMatch(10, 1)).called(1);
        verify(() => mockRepo.startSet(10, 1)).called(1);
      },
    );
  });

  group('addPointBlue', () {
    blocTest<RefereeMatchCubit, RefereeMatchState>(
      'calls updateScore with blue+1 then reloads',
      setUp: () {
        final activeSet = aMatchSet(
            id: 1, matchId: 10, number: 1, blueScore: 3,
            status: SetStatus.active);
        final matchWithSet = aMatch(
            id: 10, bluePlayer: bluePlayer, redPlayer: redPlayer,
            sets: [activeSet]);

        var callCount = 0;
        when(() => mockRepo.fetchMatchWithPlayers(10)).thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? matchWithSet : matchWithSet;
        });
        when(() => mockRepo.updateScore(10, 1, 4, 0))
            .thenAnswer((_) async {});
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.load(10);
        await cubit.addPointBlue();
      },
      skip: 2,
      expect: () => [isA<RefereeMatchReady>()],
      verify: (_) {
        verify(() => mockRepo.updateScore(10, 1, 4, 0)).called(1);
      },
    );
  });

  group('addPointRed', () {
    blocTest<RefereeMatchCubit, RefereeMatchState>(
      'calls updateScore with red+1 then reloads',
      setUp: () {
        final activeSet = aMatchSet(
            id: 1, matchId: 10, number: 1, redScore: 2,
            status: SetStatus.active);
        final matchWithSet = aMatch(
            id: 10, bluePlayer: bluePlayer, redPlayer: redPlayer,
            sets: [activeSet]);

        when(() => mockRepo.fetchMatchWithPlayers(10))
            .thenAnswer((_) async => matchWithSet);
        when(() => mockRepo.updateScore(10, 1, 0, 3))
            .thenAnswer((_) async {});
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.load(10);
        await cubit.addPointRed();
      },
      skip: 2,
      expect: () => [isA<RefereeMatchReady>()],
      verify: (_) {
        verify(() => mockRepo.updateScore(10, 1, 0, 3)).called(1);
      },
    );
  });

  group('subtractPointBlue', () {
    blocTest<RefereeMatchCubit, RefereeMatchState>(
      'clamps to 0 — calls updateScore(matchId, setNum, 0, red) when blueScore is 0',
      setUp: () {
        final activeSet = aMatchSet(
            id: 1,
            matchId: 10,
            number: 1,
            blueScore: 0,
            redScore: 5,
            status: SetStatus.active);
        final matchWithSet = aMatch(
            id: 10, bluePlayer: bluePlayer, redPlayer: redPlayer,
            sets: [activeSet]);

        when(() => mockRepo.fetchMatchWithPlayers(10))
            .thenAnswer((_) async => matchWithSet);
        when(() => mockRepo.updateScore(10, 1, 0, 5))
            .thenAnswer((_) async {});
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.load(10);
        await cubit.subtractPointBlue();
      },
      skip: 2,
      expect: () => [isA<RefereeMatchReady>()],
      verify: (_) {
        verify(() => mockRepo.updateScore(10, 1, 0, 5)).called(1);
      },
    );
  });

  group('finishSet', () {
    blocTest<RefereeMatchCubit, RefereeMatchState>(
      'calls finishSet then reloads',
      setUp: () {
        final activeSet = aMatchSet(
            id: 1, matchId: 10, number: 1, status: SetStatus.active);
        final matchWithSet = aMatch(
            id: 10, bluePlayer: bluePlayer, redPlayer: redPlayer,
            sets: [activeSet]);

        when(() => mockRepo.fetchMatchWithPlayers(10))
            .thenAnswer((_) async => matchWithSet);
        when(() => mockRepo.finishSet(10, 1)).thenAnswer((_) async {});
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.load(10);
        await cubit.finishSet(1);
      },
      skip: 2,
      expect: () => [isA<RefereeMatchReady>()],
      verify: (_) {
        verify(() => mockRepo.finishSet(10, 1)).called(1);
      },
    );
  });

  group('finishMatch', () {
    blocTest<RefereeMatchCubit, RefereeMatchState>(
      'calls finishMatch then reloads',
      setUp: () {
        when(() => mockRepo.fetchMatchWithPlayers(10))
            .thenAnswer((_) async => baseMatch);
        when(() => mockRepo.finishMatch(10)).thenAnswer((_) async {});
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.load(10);
        await cubit.finishMatch();
      },
      skip: 2,
      expect: () => [isA<RefereeMatchReady>()],
      verify: (_) {
        verify(() => mockRepo.finishMatch(10)).called(1);
      },
    );
  });

  group('finishSetAndMatch', () {
    blocTest<RefereeMatchCubit, RefereeMatchState>(
      'calls finishSet then finishMatch then reloads',
      setUp: () {
        final activeSet = aMatchSet(
            id: 1, matchId: 10, number: 1, status: SetStatus.active);
        final matchWithSet = aMatch(
            id: 10, bluePlayer: bluePlayer, redPlayer: redPlayer,
            sets: [activeSet]);

        when(() => mockRepo.fetchMatchWithPlayers(10))
            .thenAnswer((_) async => matchWithSet);
        when(() => mockRepo.finishSet(10, 1)).thenAnswer((_) async {});
        when(() => mockRepo.finishMatch(10)).thenAnswer((_) async {});
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.load(10);
        await cubit.finishSetAndMatch(1);
      },
      skip: 2,
      expect: () => [isA<RefereeMatchReady>()],
      verify: (_) {
        verify(() => mockRepo.finishSet(10, 1)).called(1);
        verify(() => mockRepo.finishMatch(10)).called(1);
      },
    );
  });

  group('technicalDefeatMatch', () {
    blocTest<RefereeMatchCubit, RefereeMatchState>(
      'calls technicalDefeatMatch then reloads',
      setUp: () {
        when(() => mockRepo.fetchMatchWithPlayers(10))
            .thenAnswer((_) async => baseMatch);
        when(() => mockRepo.technicalDefeatMatch(10, 2,
                reason: any(named: 'reason')))
            .thenAnswer((_) async {});
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.load(10);
        await cubit.technicalDefeatMatch(2);
      },
      skip: 2,
      expect: () => [isA<RefereeMatchReady>()],
      verify: (_) {
        verify(() =>
                mockRepo.technicalDefeatMatch(10, 2, reason: any(named: 'reason')))
            .called(1);
      },
    );
  });

  group('issueCard', () {
    blocTest<RefereeMatchCubit, RefereeMatchState>(
      'calls issueCard then reloads',
      setUp: () {
        when(() => mockRepo.fetchMatchWithPlayers(10))
            .thenAnswer((_) async => baseMatch);
        when(() => mockRepo.issueCard(10, 1, 'YELLOW'))
            .thenAnswer((_) async {});
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.load(10);
        await cubit.issueCard(1, 'YELLOW');
      },
      skip: 2,
      expect: () => [isA<RefereeMatchReady>()],
      verify: (_) {
        verify(() => mockRepo.issueCard(10, 1, 'YELLOW')).called(1);
      },
    );
  });

  group('revokeCard', () {
    blocTest<RefereeMatchCubit, RefereeMatchState>(
      'calls revokeCard then reloads',
      setUp: () {
        when(() => mockRepo.fetchMatchWithPlayers(10))
            .thenAnswer((_) async => baseMatch);
        when(() => mockRepo.revokeCard(10, 99)).thenAnswer((_) async {});
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.load(10);
        await cubit.revokeCard(99);
      },
      skip: 2,
      expect: () => [isA<RefereeMatchReady>()],
      verify: (_) {
        verify(() => mockRepo.revokeCard(10, 99)).called(1);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // RefereeMatchReady computed properties
  // ---------------------------------------------------------------------------

  group('RefereeMatchReady computed properties', () {
    RefereeMatchReady makeReady({
      List<MatchCard> cards = const [],
      List<MatchSet> sets = const [],
      int? firstServerId,
      int setsToWin = 3,
    }) {
      final match = aMatch(
        id: 10,
        bluePlayer: bluePlayer,
        redPlayer: redPlayer,
        cards: cards,
        sets: sets,
        firstServerId: firstServerId,
        setsToWin: setsToWin,
      );
      return RefereeMatchReady(match: match);
    }

    group('blueCards / redCards', () {
      test('blueCards returns cards where playerId == bluePlayerId', () {
        final blueCard = aMatchCard(id: 1, matchId: 10, playerId: 1, cardType: 'YELLOW');
        final redCard = aMatchCard(id: 2, matchId: 10, playerId: 2, cardType: 'YELLOW');
        final ready = makeReady(cards: [blueCard, redCard]);

        expect(ready.blueCards, [blueCard]);
        expect(ready.redCards, [redCard]);
      });
    });

    group('canIssueWhite', () {
      test('true when neither player has WHITE', () {
        final ready = makeReady();
        expect(ready.canIssueWhite, isTrue);
      });

      test('true when only blue has WHITE (red still eligible)', () {
        final blueWhite = aMatchCard(id: 1, matchId: 10, playerId: 1, cardType: 'WHITE');
        final ready = makeReady(cards: [blueWhite]);
        expect(ready.canIssueWhite, isTrue);
      });

      test('false when both players have WHITE', () {
        final blueWhite = aMatchCard(id: 1, matchId: 10, playerId: 1, cardType: 'WHITE');
        final redWhite = aMatchCard(id: 2, matchId: 10, playerId: 2, cardType: 'WHITE');
        final ready = makeReady(cards: [blueWhite, redWhite]);
        expect(ready.canIssueWhite, isFalse);
      });
    });

    group('canIssueYellow', () {
      test('true when neither player has YELLOW', () {
        final ready = makeReady();
        expect(ready.canIssueYellow, isTrue);
      });

      test('false when both players have YELLOW', () {
        final blueYellow =
            aMatchCard(id: 1, matchId: 10, playerId: 1, cardType: 'YELLOW');
        final redYellow =
            aMatchCard(id: 2, matchId: 10, playerId: 2, cardType: 'YELLOW');
        final ready = makeReady(cards: [blueYellow, redYellow]);
        expect(ready.canIssueYellow, isFalse);
      });
    });

    group('canIssueRed / eligibleRedPlayers', () {
      test('canIssueRed false when neither player has YELLOW', () {
        final ready = makeReady();
        expect(ready.canIssueRed, isFalse);
        expect(ready.eligibleRedPlayers, isEmpty);
      });

      test('canIssueRed true and blue eligible when blue has YELLOW', () {
        final blueYellow =
            aMatchCard(id: 1, matchId: 10, playerId: 1, cardType: 'YELLOW');
        final ready = makeReady(cards: [blueYellow]);
        expect(ready.canIssueRed, isTrue);
        expect(ready.eligibleRedPlayers, contains(1));
        expect(ready.eligibleRedPlayers, isNot(contains(2)));
      });

      test('both players eligible when both have YELLOW', () {
        final blueYellow =
            aMatchCard(id: 1, matchId: 10, playerId: 1, cardType: 'YELLOW');
        final redYellow =
            aMatchCard(id: 2, matchId: 10, playerId: 2, cardType: 'YELLOW');
        final ready = makeReady(cards: [blueYellow, redYellow]);
        expect(ready.eligibleRedPlayers, containsAll([1, 2]));
      });
    });

    group('isDisplaySwapped', () {
      test('odd set (1) is not swapped', () {
        final ready = makeReady(setsToWin: 3);
        expect(ready.isDisplaySwapped(1), isFalse);
      });

      test('even set (2) is swapped', () {
        final ready = makeReady(setsToWin: 3);
        expect(ready.isDisplaySwapped(2), isTrue);
      });

      test('odd set 3 is not swapped', () {
        final ready = makeReady(setsToWin: 3);
        expect(ready.isDisplaySwapped(3), isFalse);
      });

      test(
          'deciding set (5) is swapped (even) but extra-swaps back when blue reaches 5',
          () {
        // setsToWin=3 → decidingSet = 3*2-1 = 5 (odd → normally not swapped)
        // but blueScore>=5 triggers extra swap → swapped=true
        final ready = makeReady(setsToWin: 3);
        // set 5 odd → swapped starts false, blueScore=5 → !false = true
        expect(ready.isDisplaySwapped(5, blueScore: 5), isTrue);
      });

      test('deciding set (5) not swapped when no player reached 5 points', () {
        final ready = makeReady(setsToWin: 3);
        expect(ready.isDisplaySwapped(5, blueScore: 4, redScore: 4), isFalse);
      });
    });

    group('currentServerId', () {
      test('returns null when no active set', () {
        final ready = makeReady(firstServerId: 1);
        expect(ready.currentServerId(), isNull);
      });

      test('returns firstServer when active set and 0 points played (odd set)',
          () {
        final activeSet = aMatchSet(
            id: 1,
            matchId: 10,
            number: 1,
            blueScore: 0,
            redScore: 0,
            status: SetStatus.active);
        final ready = makeReady(sets: [activeSet], firstServerId: 1);
        // set 1 (odd) → setStarter = firstServer = 1
        // total=0, changes = 0 ~/ 2 = 0 → 0%2==0 → setStarter = 1
        expect(ready.currentServerId(), 1);
      });

      test('switches server after 2 points in normal play', () {
        final activeSet = aMatchSet(
            id: 1,
            matchId: 10,
            number: 1,
            blueScore: 2,
            redScore: 0,
            status: SetStatus.active);
        final ready = makeReady(sets: [activeSet], firstServerId: 1);
        // total=2, changes = 2~/ 2 = 1 → 1%2==1 → otherServer = 2
        expect(ready.currentServerId(), 2);
      });

      test('even set (2) starts with otherServer', () {
        final activeSet = aMatchSet(
            id: 1,
            matchId: 10,
            number: 2,
            blueScore: 0,
            redScore: 0,
            status: SetStatus.active);
        final ready = makeReady(sets: [activeSet], firstServerId: 1);
        // set 2 (even) → setStarter = otherServer = 2
        // total=0, changes = 0 → 0%2==0 → setStarter = 2
        expect(ready.currentServerId(), 2);
      });
    });
  });
}
