import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/services/abstract/i_match_service.dart';

class MatchRepository {
  final IMatchService _service;

  const MatchRepository(this._service);

  Future<Match?> fetchMatchById({required String matchId}) {
    return _service.fetchMatchById(matchId);
  }

  Stream<void> watchMatchChanges(String matchId) {
    return _service.watchMatchChanges(matchId);
  }
}
