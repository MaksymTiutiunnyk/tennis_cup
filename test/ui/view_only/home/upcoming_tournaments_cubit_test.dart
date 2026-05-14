import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/data/models/match_view.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/ui/view_only/home/view_models/upcoming_tournaments_cubit.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  setUpAll(registerFallbackValues);

  late MockTournamentRepository mockRepo;

  final matchView = MatchView(
    matchId: '1',
    arenaId: '1',
    arenaName: 'Arena 1',
    arenaColor: Colors.red,
    tournamentId: '10',
    tournamentGender: 'MALE',
    tournamentTime: Time.Morning,
    tournamentStart: DateTime(2024, 1, 15, 9),
    bluePlayer: aPlayer(userId: 1),
    redPlayer: aPlayer(userId: 2),
    blueScore: 0,
    redScore: 0,
  );

  setUp(() {
    mockRepo = MockTournamentRepository();
  });

  UpcomingTournamentsCubit buildCubit() =>
      UpcomingTournamentsCubit(tournamentRepository: mockRepo);

  group('auto-init _fetch', () {
    blocTest<UpcomingTournamentsCubit, UpcomingTournamentsState>(
      'success emits UpcomingTournamentsLoaded with fetched matches',
      setUp: () {
        when(() => mockRepo.fetchUpcomingMatches())
            .thenAnswer((_) async => [matchView]);
      },
      build: buildCubit,
      // constructor fires _fetch() async; wait for it to complete
      wait: const Duration(milliseconds: 10),
      expect: () => [
        isA<UpcomingTournamentsLoaded>()
            .having((s) => s.matches, 'matches', [matchView]),
      ],
    );

    blocTest<UpcomingTournamentsCubit, UpcomingTournamentsState>(
      'failure emits UpcomingTournamentsError',
      setUp: () {
        when(() => mockRepo.fetchUpcomingMatches())
            .thenAnswer((_) async => throw Exception('server error'));
      },
      build: buildCubit,
      wait: const Duration(milliseconds: 10),
      expect: () => [isA<UpcomingTournamentsError>()],
    );
  });
}
