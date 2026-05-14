import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/ui/view_only/player_details/view_models/player_tournaments_cubit.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  setUpAll(registerFallbackValues);

  late MockTournamentRepository mockRepo;

  final player = aPlayer(userId: 7);

  final tournament1 = Tournament(
    tournamentId: '1',
    name: 'T1',
    gender: 'MALE',
    status: 'ACTIVE',
    players: const [],
    date: DateTime(2024, 1, 15),
    arena: anArena(),
    time: Time.Morning,
    points: const [],
    places: const [],
  );
  final tournament2 = Tournament(
    tournamentId: '2',
    name: 'T2',
    gender: 'MALE',
    status: 'ACTIVE',
    players: const [],
    date: DateTime(2024, 2, 10),
    arena: anArena(),
    time: Time.Evening,
    points: const [],
    places: const [],
  );

  setUp(() {
    mockRepo = MockTournamentRepository();
  });

  PlayerTournamentsCubit buildCubit() =>
      PlayerTournamentsCubit(player, tournamentRepository: mockRepo);

  group('fetchTournaments', () {
    blocTest<PlayerTournamentsCubit, PlayerTournamentsState>(
      'first call emits PlayerTournamentsLoaded with hasMore=false',
      setUp: () {
        when(() => mockRepo.fetchPlayersTournaments(
              userId: '7',
              page: const PageRequest(page: 0, size: 2),
            )).thenAnswer((_) async =>
            PageResult(items: [tournament1, tournament2], hasMore: false));
      },
      build: buildCubit,
      act: (cubit) => cubit.fetchTournaments(),
      expect: () => [
        isA<PlayerTournamentsLoaded>()
            .having((s) => s.tournaments, 'tournaments',
                [tournament1, tournament2])
            .having((s) => s.hasMore, 'hasMore', false),
      ],
    );

    blocTest<PlayerTournamentsCubit, PlayerTournamentsState>(
      'hasMore=true is propagated in state',
      setUp: () {
        when(() => mockRepo.fetchPlayersTournaments(
              userId: '7',
              page: const PageRequest(page: 0, size: 2),
            )).thenAnswer((_) async =>
            PageResult(items: [tournament1, tournament2], hasMore: true));
      },
      build: buildCubit,
      act: (cubit) => cubit.fetchTournaments(),
      expect: () => [
        isA<PlayerTournamentsLoaded>()
            .having((s) => s.hasMore, 'hasMore', true),
      ],
    );

    blocTest<PlayerTournamentsCubit, PlayerTournamentsState>(
      'when state is Loaded(hasMore=false) second call is a no-op',
      setUp: () {
        when(() => mockRepo.fetchPlayersTournaments(
              userId: '7',
              page: any(named: 'page'),
            )).thenAnswer((_) async =>
            PageResult(items: [tournament1], hasMore: false));
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.fetchTournaments();
        await cubit.fetchTournaments(); // should be ignored
      },
      expect: () => [
        isA<PlayerTournamentsLoaded>()
            .having((s) => s.tournaments, 'tournaments', [tournament1])
            .having((s) => s.hasMore, 'hasMore', false),
        // no second emission
      ],
      verify: (_) {
        verify(() => mockRepo.fetchPlayersTournaments(
              userId: any(named: 'userId'),
              page: any(named: 'page'),
            )).called(1);
      },
    );

    blocTest<PlayerTournamentsCubit, PlayerTournamentsState>(
      'failure emits PlayerTournamentsError',
      setUp: () {
        when(() => mockRepo.fetchPlayersTournaments(
              userId: any(named: 'userId'),
              page: any(named: 'page'),
            )).thenThrow(Exception('server error'));
      },
      build: buildCubit,
      act: (cubit) => cubit.fetchTournaments(),
      expect: () => [isA<PlayerTournamentsError>()],
    );

    blocTest<PlayerTournamentsCubit, PlayerTournamentsState>(
      'successive calls with hasMore=true accumulate tournaments (page 2 appended)',
      setUp: () {
        when(() => mockRepo.fetchPlayersTournaments(
              userId: '7',
              page: const PageRequest(page: 0, size: 2),
            )).thenAnswer((_) async =>
            PageResult(items: [tournament1], hasMore: true));

        when(() => mockRepo.fetchPlayersTournaments(
              userId: '7',
              page: const PageRequest(page: 1, size: 2),
            )).thenAnswer((_) async =>
            PageResult(items: [tournament2], hasMore: false));
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.fetchTournaments();
        await cubit.fetchTournaments();
      },
      expect: () => [
        isA<PlayerTournamentsLoaded>()
            .having((s) => s.tournaments, 'page 1', [tournament1])
            .having((s) => s.hasMore, 'hasMore', true),
        isA<PlayerTournamentsLoaded>()
            .having((s) => s.tournaments, 'page 1+2',
                [tournament1, tournament2])
            .having((s) => s.hasMore, 'hasMore', false),
      ],
    );
  });
}
