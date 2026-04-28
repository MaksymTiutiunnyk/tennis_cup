import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/models/page_request.dart';
import 'package:tennis_cup/data/models/page_result.dart';
import 'package:tennis_cup/data/services/abstract/i_match_service.dart';

class MatchRepository {
  final IMatchService _service;

  const MatchRepository(this._service);

  Future<Match?> fetchMatchById({required String matchId}) {
    return _service.fetchMatchById(matchId);
  }

  Future<PageResult<Match>> fetchPlayersMatches({
    required String player1Id,
    String? player2Id,
    required PageRequest page,
  }) {
    return _service.fetchPlayersMatches(
      playerId: player1Id,
      player2Id: player2Id,
      page: page,
    );
  }

  Stream<void> watchMatchChanges(String matchId) {
    return _service.watchMatchChanges(matchId);
  }
}
