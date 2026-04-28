import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/models/page_request.dart';
import 'package:tennis_cup/data/models/page_result.dart';

abstract interface class IMatchService {
  Future<Match?> fetchMatchById(String id);
  Stream<void> watchMatchChanges(String matchId);
  Future<PageResult<Match>> fetchPlayersMatches({
    required String playerId,
    String? player2Id,
    required PageRequest page,
  });
}
