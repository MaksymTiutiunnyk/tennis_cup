import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/model/arena.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/providers/arena_filter_provider.dart';
import 'package:tennis_cup/providers/schedule_date_provider.dart';
import 'package:tennis_cup/providers/time_filter_provider.dart';
import 'package:tennis_cup/repositories/tournament_repository.dart';

final scheduledTournamentProvider =
    FutureProvider<List<Tournament>>((ref) async {
  final DateTime tournamentDate = ref.watch(scheduleDateProvider);
  final Arena tournamentArena = ref.watch(arenaFilterProvider);
  final Time tournamentTime = ref.watch(timeFilterProvider);

  return await TournamentRepository.fetchScheduledTournament(
      tournamentDate: tournamentDate,
      tournamentArena: tournamentArena,
      tournamentTime: tournamentTime);
});
