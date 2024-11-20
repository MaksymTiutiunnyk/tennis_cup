import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/repositories/tournament_repository.dart';

final liveStreamAndUpcomingMatchesTournamentsProvider =
    StreamProvider.autoDispose<List<Tournament>>((ref) async* {
  List<Tournament> tournaments =
      await TournamentRepository.fetchLiveStreamAndUpcomingMatchesTournaments();
  yield tournaments;

  final tournamentIds =
      tournaments.map((tournament) => tournament.tournamentId).toList();

  await for (final _ in TournamentRepository.watchMatchChanges(tournamentIds)) {
    tournaments = await TournamentRepository
        .fetchLiveStreamAndUpcomingMatchesTournaments();
    yield tournaments;
  }
});
