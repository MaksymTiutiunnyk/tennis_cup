import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/page_request.dart';
import 'package:tennis_cup/data/models/page_result.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/services/abstract/i_tournament_service.dart';

class TournamentRepository {
  final ITournamentService _service;

  const TournamentRepository(this._service);

  Future<List<Tournament>> fetchScheduledTournament({
    required DateTime tournamentDate,
    required Arena tournamentArena,
    required Time tournamentTime,
  }) {
    return _service.fetchScheduledTournaments(
      date: tournamentDate,
      arena: tournamentArena,
      time: tournamentTime,
    );
  }

  Future<List<Tournament>> fetchLiveStreamMatchesTournaments() {
    return _service.fetchRecentTournaments();
  }

  Future<List<Tournament>> fetchUpcomingMatchesTournaments() {
    return _service.fetchUpcomingTournaments();
  }

  Future<List<Tournament>> fetchWinnersTournaments() {
    return _service.fetchRecentTournaments();
  }

  Stream<void> watchTournamentChanges(String tournamentId) {
    return _service.watchTournamentChanges(tournamentId);
  }

  Future<PageResult<Tournament>> fetchPlayersTournaments({
    required String player1Id,
    String? player2Id,
    required PageRequest page,
  }) {
    return _service.fetchPlayerTournaments(
      playerId: player1Id,
      player2Id: player2Id,
      page: page,
    );
  }

  Future<Tournament> fetchTournamentById({required String tournamentId}) {
    return _service.fetchTournamentById(tournamentId);
  }
}
