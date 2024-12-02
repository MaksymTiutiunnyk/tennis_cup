import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/logic/riverpod/arena_filter_provider.dart';
import 'package:tennis_cup/logic/riverpod/schedule_date_provider.dart';
import 'package:tennis_cup/logic/riverpod/time_filter_provider.dart';
import 'package:tennis_cup/data/repositories/tournament_repository.dart';

final scheduledTournamentProvider =
    StreamProvider.autoDispose<List<Tournament>>((ref) async* {
  final DateTime tournamentDate = ref.watch(scheduleDateProvider);
  final Arena tournamentArena = ref.watch(arenaFilterProvider);
  final Time tournamentTime = ref.watch(timeFilterProvider);

  List<Tournament> tournaments =
      await TournamentRepository.fetchScheduledTournament(
          tournamentDate: tournamentDate,
          tournamentArena: tournamentArena,
          tournamentTime: tournamentTime);

  yield tournaments;

  if (tournaments.isEmpty) {
    return;
  }

  await for (final _ in TournamentRepository.watchMatchChanges(
      tournaments.first.tournamentId)) {
    tournaments = await TournamentRepository.fetchScheduledTournament(
        tournamentDate: tournamentDate,
        tournamentArena: tournamentArena,
        tournamentTime: tournamentTime);
    yield tournaments;
  }
});
