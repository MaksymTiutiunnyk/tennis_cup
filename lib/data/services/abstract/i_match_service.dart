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
  Future<PageResult<HeadToHeadMatchDto>> fetchHeadToHead({
    required int player1Id,
    required int player2Id,
    required PageRequest page,
  });

  // Referee match lifecycle
  Future<MatchDto> startMatch(int matchId);
  Future<MatchDto> finishMatch(int matchId);
  Future<MatchSetDto> startSet(int matchId, int setNumber);
  Future<MatchSetDto> updateScore(
      int matchId, int setNumber, int blueScore, int redScore);
  Future<MatchSetDto> finishSet(int matchId, int setNumber);
  Future<MatchDto> technicalDefeatMatch(int matchId, int loserId,
      {String? reason});
  Future<MatchSetDto> technicalDefeatSet(int matchId, int setNumber,
      int loserId, {String? reason});
}
