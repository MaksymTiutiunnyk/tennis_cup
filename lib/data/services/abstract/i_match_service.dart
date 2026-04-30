import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/data/services/dto/match_dto.dart';

abstract interface class IMatchService {
  Future<MatchDto?> fetchMatchById(String id);
  Stream<void> watchMatchChanges(String matchId);
  Future<List<MatchDto>> fetchTournamentMatches(String tournamentId);
  Future<PageResult<MatchDto>> fetchPlayersMatches({
    required String playerId,
    String? player2Id,
    required PageRequest page,
  });
}
