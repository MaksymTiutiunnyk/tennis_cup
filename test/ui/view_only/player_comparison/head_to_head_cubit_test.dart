import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/ui/view_only/player_comparison/view_models/head_to_head_cubit.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  setUpAll(registerFallbackValues);

  late MockMatchRepository mockRepo;

  final player1 = aPlayer(userId: 1, name: 'Alice');
  final player2 = aPlayer(userId: 2, name: 'Bob');

  final match1 = Match(
    matchId: '1',
    bluePlayer: player1,
    redPlayer: player2,
    blueScore: 2,
    redScore: 1,
    blueSetScores: const [11, 11],
    redSetScores: const [5, 8],
    tournamentId: '10',
    dateTime: DateTime(2024, 1, 15),
  );
  final match2 = Match(
    matchId: '2',
    bluePlayer: player1,
    redPlayer: player2,
    blueScore: 1,
    redScore: 2,
    blueSetScores: const [8, 11, 7],
    redSetScores: const [11, 5, 11],
    tournamentId: '10',
    dateTime: DateTime(2024, 2, 20),
  );

  setUp(() {
    mockRepo = MockMatchRepository();
  });

  HeadToHeadCubit buildCubit() =>
      HeadToHeadCubit(player1, player2, matchRepository: mockRepo);

  group('fetch', () {
    blocTest<HeadToHeadCubit, HeadToHeadState>(
      'first call success emits HeadToHeadLoaded with hasMore=false',
      setUp: () {
        when(() => mockRepo.fetchHeadToHead(
              userId1: 1,
              userId2: 2,
              page: const PageRequest(page: 0, size: 10),
            )).thenAnswer((_) async =>
            PageResult(items: [match1, match2], hasMore: false));
      },
      build: buildCubit,
      act: (cubit) => cubit.fetch(),
      expect: () => [
        isA<HeadToHeadLoaded>()
            .having((s) => s.matches, 'matches', [match1, match2])
            .having((s) => s.hasMore, 'hasMore', false),
      ],
    );

    blocTest<HeadToHeadCubit, HeadToHeadState>(
      'hasMore=true is propagated and next call advances page',
      setUp: () {
        when(() => mockRepo.fetchHeadToHead(
              userId1: 1,
              userId2: 2,
              page: const PageRequest(page: 0, size: 10),
            )).thenAnswer((_) async =>
            PageResult(items: [match1], hasMore: true));

        when(() => mockRepo.fetchHeadToHead(
              userId1: 1,
              userId2: 2,
              page: const PageRequest(page: 1, size: 10),
            )).thenAnswer((_) async =>
            PageResult(items: [match2], hasMore: false));
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.fetch();
        await cubit.fetch();
      },
      expect: () => [
        isA<HeadToHeadLoaded>()
            .having((s) => s.matches, 'page 1', [match1])
            .having((s) => s.hasMore, 'hasMore', true),
        isA<HeadToHeadLoaded>()
            .having((s) => s.matches, 'page 1+2', [match1, match2])
            .having((s) => s.hasMore, 'hasMore', false),
      ],
    );

    blocTest<HeadToHeadCubit, HeadToHeadState>(
      'when already Loaded(hasMore=false) further fetch is a no-op',
      setUp: () {
        when(() => mockRepo.fetchHeadToHead(
              userId1: any(named: 'userId1'),
              userId2: any(named: 'userId2'),
              page: any(named: 'page'),
            )).thenAnswer((_) async =>
            PageResult(items: [match1], hasMore: false));
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.fetch();
        await cubit.fetch(); // should be ignored
      },
      expect: () => [
        isA<HeadToHeadLoaded>()
            .having((s) => s.matches, 'matches', [match1])
            .having((s) => s.hasMore, 'hasMore', false),
      ],
      verify: (_) {
        verify(() => mockRepo.fetchHeadToHead(
              userId1: any(named: 'userId1'),
              userId2: any(named: 'userId2'),
              page: any(named: 'page'),
            )).called(1);
      },
    );

    blocTest<HeadToHeadCubit, HeadToHeadState>(
      'failure emits HeadToHeadError',
      setUp: () {
        when(() => mockRepo.fetchHeadToHead(
              userId1: any(named: 'userId1'),
              userId2: any(named: 'userId2'),
              page: any(named: 'page'),
            )).thenThrow(Exception('server error'));
      },
      build: buildCubit,
      act: (cubit) => cubit.fetch(),
      expect: () => [isA<HeadToHeadError>()],
    );

    blocTest<HeadToHeadCubit, HeadToHeadState>(
      '_isLoading guard prevents concurrent fetches from duplicating results',
      setUp: () {
        when(() => mockRepo.fetchHeadToHead(
              userId1: any(named: 'userId1'),
              userId2: any(named: 'userId2'),
              page: any(named: 'page'),
            )).thenAnswer((_) async =>
            PageResult(items: [match1], hasMore: true));
      },
      build: buildCubit,
      act: (cubit) async {
        // fire two fetches without awaiting the first — second should be dropped
        final f1 = cubit.fetch();
        final f2 = cubit.fetch();
        await Future.wait([f1, f2]);
      },
      expect: () => [
        isA<HeadToHeadLoaded>()
            .having((s) => s.matches, 'single fetch result', [match1]),
      ],
      verify: (_) {
        verify(() => mockRepo.fetchHeadToHead(
              userId1: any(named: 'userId1'),
              userId2: any(named: 'userId2'),
              page: any(named: 'page'),
            )).called(1);
      },
    );
  });
}
