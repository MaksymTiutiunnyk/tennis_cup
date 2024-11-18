import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/repositories/tournament_repository.dart';

final winnersTournamentsProvider =
    FutureProvider<List<Tournament>>((ref) async {
  return await TournamentRepository.fetchWinnersTournaments();
});
