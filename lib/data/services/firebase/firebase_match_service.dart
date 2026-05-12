import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/data/services/abstract/i_match_service.dart';
import 'package:tennis_cup/data/services/dto/match_dto.dart';

class FirebaseMatchService implements IMatchService {
  const FirebaseMatchService();

  @override
  Future<MatchDto?> fetchMatchById(String id) async {
    throw UnimplementedError(
        'FirebaseMatchService is deprecated; use RestMatchService.');
  }

  @override
  Stream<MatchDto> watchMatchChanges(String matchId) => const Stream.empty();

  @override
  Future<List<MatchDto>> fetchTournamentMatches(String tournamentId) async {
    throw UnimplementedError(
        'FirebaseMatchService is deprecated; use RestMatchService.');
  }

  @override
  Future<PageResult<MatchDto>> fetchPlayersMatches({
    required String playerId,
    String? player2Id,
    required PageRequest page,
  }) {
    throw UnimplementedError(
        'FirebaseMatchService is deprecated; use RestMatchService.');
  }

  @override
  Future<PageResult<HeadToHeadMatchDto>> fetchHeadToHead({
    required int userId1,
    required int userId2,
    required PageRequest page,
  }) {
    throw UnimplementedError(
        'FirebaseMatchService is deprecated; use RestMatchService.');
  }

  @override
  Future<MatchDto> startMatch(int matchId, int firstServerId) =>
      throw UnimplementedError(
          'FirebaseMatchService is deprecated; use RestMatchService.');

  @override
  Future<MatchDto> finishMatch(int matchId) => throw UnimplementedError(
      'FirebaseMatchService is deprecated; use RestMatchService.');

  @override
  Future<MatchSetDto> startSet(int matchId, int setNumber) =>
      throw UnimplementedError(
          'FirebaseMatchService is deprecated; use RestMatchService.');

  @override
  Future<MatchSetDto> updateScore(
          int matchId, int setNumber, int blueScore, int redScore) =>
      throw UnimplementedError(
          'FirebaseMatchService is deprecated; use RestMatchService.');

  @override
  Future<MatchSetDto> finishSet(int matchId, int setNumber) =>
      throw UnimplementedError(
          'FirebaseMatchService is deprecated; use RestMatchService.');

  @override
  Future<MatchDto> technicalDefeatMatch(int matchId, int loserId,
          {String? reason}) =>
      throw UnimplementedError(
          'FirebaseMatchService is deprecated; use RestMatchService.');

  @override
  Future<MatchSetDto> technicalDefeatSet(
          int matchId, int setNumber, int loserId, {String? reason}) =>
      throw UnimplementedError(
          'FirebaseMatchService is deprecated; use RestMatchService.');

  @override
  Future<MatchDto> issueCard(int matchId, int playerId, String cardType) =>
      throw UnimplementedError(
          'FirebaseMatchService is deprecated; use RestMatchService.');

  @override
  Future<MatchDto> revokeCard(int matchId, int cardId) =>
      throw UnimplementedError(
          'FirebaseMatchService is deprecated; use RestMatchService.');
}
