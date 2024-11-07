import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/data/tournaments.dart';
import 'package:tennis_cup/model/arena.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/providers/arena_filter_provider.dart';
import 'package:tennis_cup/providers/schedule_date_provider.dart';
import 'package:tennis_cup/providers/time_filter_provider.dart';

final scheduledTournamentProvider = Provider<List<Tournament>>((ref) {
  final DateTime tournamentDate = ref.watch(scheduleDateProvider);
  final Arena tournamentArena = ref.watch(arenaFilterProvider);
  final Time tournamentTime = ref.watch(timeFilterProvider);

  List<Tournament> filteredTournaments = tournaments
      .where((tournament) =>
          tournament.date == tournamentDate &&
          tournament.time == tournamentTime &&
          tournament.arena == tournamentArena)
      .toList();

  return filteredTournaments;
});
