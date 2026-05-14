import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/scheduled_tournament_cubit.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValues();
    registerFallbackValue(anArena());
    registerFallbackValue(Time.Morning);
    registerFallbackValue(DateTime(2024));
  });

  late MockTournamentRepository mockRepo;

  final testDate = DateTime(2024, 1, 15);
  final testArena = anArena();
  const testTime = Time.Morning;
  final testTournament = Tournament(
    tournamentId: '1',
    name: 'Test Tournament',
    gender: 'MALE',
    status: 'ACTIVE',
    players: const [],
    date: DateTime(2024, 1, 15),
    arena: const Arena(id: '1', title: 'Arena 1', color: Color(0xFFFF0000)),
    time: Time.Morning,
    points: const [],
    places: const [],
  );

  setUp(() {
    mockRepo = MockTournamentRepository();
  });

  ScheduledTournamentCubit buildCubit() =>
      ScheduledTournamentCubit(tournamentRepository: mockRepo);

  void stubFetch(List<Tournament> result) {
    when(() => mockRepo.fetchScheduledTournament(
          tournamentDate: any(named: 'tournamentDate'),
          tournamentArena: any(named: 'tournamentArena'),
          tournamentTime: any(named: 'tournamentTime'),
          statuses: any(named: 'statuses'),
        )).thenAnswer((_) async => result);
  }

  void stubFetchThrows() {
    when(() => mockRepo.fetchScheduledTournament(
          tournamentDate: any(named: 'tournamentDate'),
          tournamentArena: any(named: 'tournamentArena'),
          tournamentTime: any(named: 'tournamentTime'),
          statuses: any(named: 'statuses'),
        )).thenThrow(Exception('server error'));
  }

  group('fetchScheduledTournament', () {
    blocTest<ScheduledTournamentCubit, ScheduledTournamentState>(
      'success with results emits [Fetching, ScheduledTournamentFetched(tournament.first)]',
      setUp: () => stubFetch([testTournament]),
      build: buildCubit,
      act: (cubit) => cubit.fetchScheduledTournament(
        date: testDate,
        arena: testArena,
        time: testTime,
      ),
      expect: () => [
        isA<ScheduledTournamentFetching>(),
        isA<ScheduledTournamentFetched>()
            .having((s) => s.tournament, 'tournament', testTournament),
      ],
      verify: (_) {
        verify(() => mockRepo.fetchScheduledTournament(
              tournamentDate: testDate,
              tournamentArena: testArena,
              tournamentTime: testTime,
              statuses: ['ACTIVE', 'FINISHED'],
            )).called(1);
      },
    );

    blocTest<ScheduledTournamentCubit, ScheduledTournamentState>(
      'empty list emits [Fetching, TournamentNotFound]',
      setUp: () => stubFetch([]),
      build: buildCubit,
      act: (cubit) => cubit.fetchScheduledTournament(
        date: testDate,
        arena: testArena,
        time: testTime,
      ),
      expect: () => [
        isA<ScheduledTournamentFetching>(),
        isA<TournamentNotFound>(),
      ],
    );

    blocTest<ScheduledTournamentCubit, ScheduledTournamentState>(
      'failure emits [Fetching, ScheduledTournamentError]',
      setUp: stubFetchThrows,
      build: buildCubit,
      act: (cubit) => cubit.fetchScheduledTournament(
        date: testDate,
        arena: testArena,
        time: testTime,
      ),
      expect: () => [
        isA<ScheduledTournamentFetching>(),
        isA<ScheduledTournamentError>(),
      ],
    );
  });

  group('fetchScheduledTournamentWithoutLoading', () {
    blocTest<ScheduledTournamentCubit, ScheduledTournamentState>(
      'success emits [ScheduledTournamentFetched] without Fetching state',
      setUp: () => stubFetch([testTournament]),
      build: buildCubit,
      act: (cubit) => cubit.fetchScheduledTournamentWithoutLoading(
        date: testDate,
        arena: testArena,
        time: testTime,
      ),
      expect: () => [
        isA<ScheduledTournamentFetched>()
            .having((s) => s.tournament, 'tournament', testTournament),
      ],
    );

    blocTest<ScheduledTournamentCubit, ScheduledTournamentState>(
      'empty list emits nothing (returns early)',
      setUp: () => stubFetch([]),
      build: buildCubit,
      act: (cubit) => cubit.fetchScheduledTournamentWithoutLoading(
        date: testDate,
        arena: testArena,
        time: testTime,
      ),
      expect: () => const [],
    );

    blocTest<ScheduledTournamentCubit, ScheduledTournamentState>(
      'failure emits [ScheduledTournamentError]',
      setUp: stubFetchThrows,
      build: buildCubit,
      act: (cubit) => cubit.fetchScheduledTournamentWithoutLoading(
        date: testDate,
        arena: testArena,
        time: testTime,
      ),
      expect: () => [isA<ScheduledTournamentError>()],
    );
  });
}
