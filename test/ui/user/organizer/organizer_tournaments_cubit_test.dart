import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/models/tournament_request.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/organizer_tournaments_cubit.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  setUpAll(registerFallbackValues);

  late MockTournamentRepository mockRepo;

  final testDate = DateTime(2024, 1, 15);
  final testArena = anArena();
  const testTime = Time.Morning;

  final testTournament = Tournament(
    tournamentId: '1',
    name: 'Test Tournament',
    gender: 'MALE',
    status: TournamentStatus.pending,
    players: const [],
    date: DateTime(2024, 1, 15),
    arena: const Arena(id: '1', title: 'Arena 1', color: ArenaColor.red),
    time: Time.Morning,
    points: const [],
    places: const [],
  );

  final testRequest = CreateUpdateTournamentRequest(
    name: 'Test',
    type: 'MORNING',
    gender: 'MALE',
    startTime: DateTime(2024, 1, 15, 9),
    arenaId: 1,
    refereeIds: const [],
    matchDurationMinutes: 30,
    requiredPlayersCount: 4,
    setsToWin: 2,
    playerIds: const [],
  );

  setUp(() {
    mockRepo = MockTournamentRepository();
  });

  OrganizerTournamentsCubit buildCubit() =>
      OrganizerTournamentsCubit(repository: mockRepo);

  group('initial state', () {
    test('is OrgTournamentsLoading', () {
      final cubit = buildCubit();
      expect(cubit.state, isA<OrgTournamentsLoading>());
      cubit.close();
    });
  });

  group('load', () {
    blocTest<OrganizerTournamentsCubit, OrganizerTournamentsState>(
      'success emits [OrgTournamentsLoading, OrgTournamentsLoaded]',
      setUp: () {
        when(() => mockRepo.fetchScheduledTournament(
              tournamentDate: any(named: 'tournamentDate'),
              tournamentArena: any(named: 'tournamentArena'),
              tournamentTime: any(named: 'tournamentTime'),
              statuses: any(named: 'statuses'),
            )).thenAnswer((_) async => [testTournament]);
      },
      build: buildCubit,
      act: (cubit) => cubit.load(
        date: testDate,
        arena: testArena,
        time: testTime,
      ),
      expect: () => [
        isA<OrgTournamentsLoading>(),
        isA<OrgTournamentsLoaded>()
            .having((s) => s.tournaments, 'tournaments', [testTournament]),
      ],
    );

    blocTest<OrganizerTournamentsCubit, OrganizerTournamentsState>(
      'failure emits [OrgTournamentsLoading, OrgTournamentsError] with non-empty message',
      setUp: () {
        when(() => mockRepo.fetchScheduledTournament(
              tournamentDate: any(named: 'tournamentDate'),
              tournamentArena: any(named: 'tournamentArena'),
              tournamentTime: any(named: 'tournamentTime'),
              statuses: any(named: 'statuses'),
            )).thenThrow(Exception('server error'));
      },
      build: buildCubit,
      act: (cubit) => cubit.load(
        date: testDate,
        arena: testArena,
        time: testTime,
      ),
      expect: () => [
        isA<OrgTournamentsLoading>(),
        isA<OrgTournamentsError>()
            .having((s) => s.message, 'message', isNotEmpty),
      ],
    );
  });

  group('create', () {
    blocTest<OrganizerTournamentsCubit, OrganizerTournamentsState>(
      'success calls createTournament then reloads with loaded state',
      setUp: () {
        when(() => mockRepo.createTournament(any())).thenAnswer((_) async {});
        when(() => mockRepo.fetchScheduledTournament(
              tournamentDate: any(named: 'tournamentDate'),
              tournamentArena: any(named: 'tournamentArena'),
              tournamentTime: any(named: 'tournamentTime'),
              statuses: any(named: 'statuses'),
            )).thenAnswer((_) async => [testTournament]);
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.load(date: testDate, arena: testArena, time: testTime);
        await cubit.create(testRequest);
      },
      skip: 2,
      expect: () => [
        isA<OrgTournamentsLoading>(),
        isA<OrgTournamentsLoaded>()
            .having((s) => s.tournaments, 'tournaments', [testTournament]),
      ],
      verify: (_) {
        verify(() => mockRepo.createTournament(any())).called(1);
        verify(() => mockRepo.fetchScheduledTournament(
              tournamentDate: any(named: 'tournamentDate'),
              tournamentArena: any(named: 'tournamentArena'),
              tournamentTime: any(named: 'tournamentTime'),
              statuses: any(named: 'statuses'),
            )).called(2);
      },
    );

    blocTest<OrganizerTournamentsCubit, OrganizerTournamentsState>(
      'failure emits OrgTournamentsError',
      setUp: () {
        when(() => mockRepo.fetchScheduledTournament(
              tournamentDate: any(named: 'tournamentDate'),
              tournamentArena: any(named: 'tournamentArena'),
              tournamentTime: any(named: 'tournamentTime'),
              statuses: any(named: 'statuses'),
            )).thenAnswer((_) async => [testTournament]);
        when(() => mockRepo.createTournament(any()))
            .thenThrow(Exception('create failed'));
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.load(date: testDate, arena: testArena, time: testTime);
        await cubit.create(testRequest);
      },
      skip: 2,
      expect: () => [isA<OrgTournamentsError>()],
    );
  });

  group('update', () {
    blocTest<OrganizerTournamentsCubit, OrganizerTournamentsState>(
      'success calls updateTournament then reloads',
      setUp: () {
        when(() => mockRepo.updateTournament(any(), any()))
            .thenAnswer((_) async {});
        when(() => mockRepo.fetchScheduledTournament(
              tournamentDate: any(named: 'tournamentDate'),
              tournamentArena: any(named: 'tournamentArena'),
              tournamentTime: any(named: 'tournamentTime'),
              statuses: any(named: 'statuses'),
            )).thenAnswer((_) async => [testTournament]);
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.load(date: testDate, arena: testArena, time: testTime);
        await cubit.update(1, testRequest);
      },
      skip: 2,
      expect: () => [
        isA<OrgTournamentsLoading>(),
        isA<OrgTournamentsLoaded>(),
      ],
      verify: (_) {
        verify(() => mockRepo.updateTournament(1, any())).called(1);
      },
    );
  });

  group('delete', () {
    final tournament1 = Tournament(
      tournamentId: '1',
      name: 'T1',
      gender: 'MALE',
      status: TournamentStatus.pending,
      players: const [],
      date: DateTime(2024, 1, 15),
      arena: const Arena(id: '1', title: 'Arena 1', color: ArenaColor.red),
      time: Time.Morning,
      points: const [],
      places: const [],
    );
    final tournament2 = Tournament(
      tournamentId: '2',
      name: 'T2',
      gender: 'MALE',
      status: TournamentStatus.pending,
      players: const [],
      date: DateTime(2024, 1, 15),
      arena: const Arena(id: '1', title: 'Arena 1', color: ArenaColor.red),
      time: Time.Morning,
      points: const [],
      places: const [],
    );

    blocTest<OrganizerTournamentsCubit, OrganizerTournamentsState>(
      'success: optimistically removes tournament, no further state after delete',
      setUp: () {
        when(() => mockRepo.deleteTournament(any())).thenAnswer((_) async {});
      },
      build: buildCubit,
      seed: () => OrgTournamentsLoaded([tournament1, tournament2]),
      act: (cubit) => cubit.delete(1),
      expect: () => [
        isA<OrgTournamentsLoaded>().having(
          (s) => s.tournaments,
          'tournaments without id 1',
          [tournament2],
        ),
      ],
    );

    blocTest<OrganizerTournamentsCubit, OrganizerTournamentsState>(
      'failure: restores original state then emits OrgTournamentsError',
      setUp: () {
        when(() => mockRepo.deleteTournament(any()))
            .thenThrow(Exception('delete failed'));
      },
      build: buildCubit,
      seed: () => OrgTournamentsLoaded([tournament1, tournament2]),
      act: (cubit) => cubit.delete(1),
      expect: () => [
        isA<OrgTournamentsLoaded>().having(
          (s) => s.tournaments,
          'after optimistic removal',
          [tournament2],
        ),
        isA<OrgTournamentsLoaded>().having(
          (s) => s.tournaments,
          'restored',
          [tournament1, tournament2],
        ),
        isA<OrgTournamentsError>(),
      ],
    );
  });

  group('start', () {
    blocTest<OrganizerTournamentsCubit, OrganizerTournamentsState>(
      'success calls startTournament then reloads',
      setUp: () {
        when(() => mockRepo.startTournament(any())).thenAnswer((_) async {});
        when(() => mockRepo.fetchScheduledTournament(
              tournamentDate: any(named: 'tournamentDate'),
              tournamentArena: any(named: 'tournamentArena'),
              tournamentTime: any(named: 'tournamentTime'),
              statuses: any(named: 'statuses'),
            )).thenAnswer((_) async => [testTournament]);
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.load(date: testDate, arena: testArena, time: testTime);
        await cubit.start(1);
      },
      skip: 2,
      expect: () => [
        isA<OrgTournamentsLoading>(),
        isA<OrgTournamentsLoaded>(),
      ],
      verify: (_) {
        verify(() => mockRepo.startTournament(1)).called(1);
      },
    );
  });

  group('finish', () {
    blocTest<OrganizerTournamentsCubit, OrganizerTournamentsState>(
      'success calls finishTournament then reloads',
      setUp: () {
        when(() => mockRepo.finishTournament(any())).thenAnswer((_) async {});
        when(() => mockRepo.fetchScheduledTournament(
              tournamentDate: any(named: 'tournamentDate'),
              tournamentArena: any(named: 'tournamentArena'),
              tournamentTime: any(named: 'tournamentTime'),
              statuses: any(named: 'statuses'),
            )).thenAnswer((_) async => [testTournament]);
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.load(date: testDate, arena: testArena, time: testTime);
        await cubit.finish(1);
      },
      skip: 2,
      expect: () => [
        isA<OrgTournamentsLoading>(),
        isA<OrgTournamentsLoaded>(),
      ],
      verify: (_) {
        verify(() => mockRepo.finishTournament(1)).called(1);
      },
    );
  });

  group('addPlayers', () {
    blocTest<OrganizerTournamentsCubit, OrganizerTournamentsState>(
      'success calls addPlayers then reloads',
      setUp: () {
        when(() => mockRepo.addPlayers(any(), any())).thenAnswer((_) async {});
        when(() => mockRepo.fetchScheduledTournament(
              tournamentDate: any(named: 'tournamentDate'),
              tournamentArena: any(named: 'tournamentArena'),
              tournamentTime: any(named: 'tournamentTime'),
              statuses: any(named: 'statuses'),
            )).thenAnswer((_) async => [testTournament]);
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.load(date: testDate, arena: testArena, time: testTime);
        await cubit.addPlayers(1, [10, 11]);
      },
      skip: 2,
      expect: () => [
        isA<OrgTournamentsLoading>(),
        isA<OrgTournamentsLoaded>(),
      ],
      verify: (_) {
        verify(() => mockRepo.addPlayers(1, [10, 11])).called(1);
      },
    );
  });

  group('removePlayers', () {
    blocTest<OrganizerTournamentsCubit, OrganizerTournamentsState>(
      'success calls removePlayers then reloads',
      setUp: () {
        when(() => mockRepo.removePlayers(any(), any()))
            .thenAnswer((_) async {});
        when(() => mockRepo.fetchScheduledTournament(
              tournamentDate: any(named: 'tournamentDate'),
              tournamentArena: any(named: 'tournamentArena'),
              tournamentTime: any(named: 'tournamentTime'),
              statuses: any(named: 'statuses'),
            )).thenAnswer((_) async => [testTournament]);
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.load(date: testDate, arena: testArena, time: testTime);
        await cubit.removePlayers(1, [10]);
      },
      skip: 2,
      expect: () => [
        isA<OrgTournamentsLoading>(),
        isA<OrgTournamentsLoaded>(),
      ],
      verify: (_) {
        verify(() => mockRepo.removePlayers(1, [10])).called(1);
      },
    );
  });

  group('_reload before load', () {
    blocTest<OrganizerTournamentsCubit, OrganizerTournamentsState>(
      '_reload before load() called makes no repository call',
      setUp: () {
        when(() => mockRepo.createTournament(any())).thenAnswer((_) async {});
      },
      build: buildCubit,
      // create triggers _reload, but _date/_arena/_time are null → returns early
      act: (cubit) => cubit.create(testRequest),
      expect: () => const [],
      verify: (_) {
        verifyNever(() => mockRepo.fetchScheduledTournament(
              tournamentDate: any(named: 'tournamentDate'),
              tournamentArena: any(named: 'tournamentArena'),
              tournamentTime: any(named: 'tournamentTime'),
              statuses: any(named: 'statuses'),
            ));
      },
    );
  });

  group('fetchScheduledTournament statuses', () {
    blocTest<OrganizerTournamentsCubit, OrganizerTournamentsState>(
      'load passes all four statuses to repository',
      setUp: () {
        when(() => mockRepo.fetchScheduledTournament(
              tournamentDate: any(named: 'tournamentDate'),
              tournamentArena: any(named: 'tournamentArena'),
              tournamentTime: any(named: 'tournamentTime'),
              statuses: any(named: 'statuses'),
            )).thenAnswer((_) async => []);
      },
      build: buildCubit,
      act: (cubit) => cubit.load(
        date: testDate,
        arena: testArena,
        time: testTime,
      ),
      verify: (_) {
        verify(() => mockRepo.fetchScheduledTournament(
              tournamentDate: any(named: 'tournamentDate'),
              tournamentArena: any(named: 'tournamentArena'),
              tournamentTime: any(named: 'tournamentTime'),
              statuses: ['PENDING', 'ACTIVE', 'FINISHED', 'CANCELLED'],
            )).called(1);
      },
    );
  });
}
