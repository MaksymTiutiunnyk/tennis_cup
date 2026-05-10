import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/services/abstract/i_match_service.dart';
import 'package:tennis_cup/data/services/abstract/i_player_service.dart';
import 'package:tennis_cup/data/services/abstract/i_tournament_service.dart';
import 'package:tennis_cup/data/services/dto/match_dto.dart';
import 'package:tennis_cup/data/services/dto/tournament_dto.dart';

class RefereeRepository {
  final ITournamentService _tournamentService;
  final IMatchService _matchService;
  final IPlayerService _playerService;

  const RefereeRepository(
      this._tournamentService, this._matchService, this._playerService);

  Future<List<TournamentDto>> fetchActiveTournamentsForReferee(
      String userId) async {
    final refereeId = int.tryParse(userId) ?? -1;
    final result = await _tournamentService.fetchActiveTournamentsForReferee(
      const PageRequest(page: 0, size: 100),
      refereeId.toString(),
    );
    return result.items.where((dto) => dto.refereeId == refereeId).toList();
  }

  Future<List<MatchDto>> fetchMatchesForTournament(int tournamentId) =>
      _matchService.fetchTournamentMatches(tournamentId.toString());

  Future<({MatchDto match, Player blue, Player red})> fetchMatchWithPlayers(
      int matchId) async {
    final dto = await _matchService.fetchMatchById(matchId.toString());
    if (dto == null) throw Exception('Match $matchId not found');
    final blueF = _playerService.fetchPlayerById(dto.bluePlayerId!);
    final redF = _playerService.fetchPlayerById(dto.redPlayerId!);
    return (match: dto, blue: await blueF, red: await redF);
  }

  Future<MatchDto> startMatch(int matchId) => _matchService.startMatch(matchId);

  Future<MatchDto> finishMatch(int matchId) =>
      _matchService.finishMatch(matchId);

  Future<MatchSetDto> startSet(int matchId, int setNumber) =>
      _matchService.startSet(matchId, setNumber);

  Future<MatchSetDto> updateScore(
          int matchId, int setNumber, int blueScore, int redScore) =>
      _matchService.updateScore(matchId, setNumber, blueScore, redScore);

  Future<MatchSetDto> finishSet(int matchId, int setNumber) =>
      _matchService.finishSet(matchId, setNumber);

  Future<MatchDto> technicalDefeatMatch(int matchId, int loserId,
          {String? reason}) =>
      _matchService.technicalDefeatMatch(matchId, loserId, reason: reason);

  Future<MatchSetDto> technicalDefeatSet(
          int matchId, int setNumber, int loserId, {String? reason}) =>
      _matchService.technicalDefeatSet(matchId, setNumber, loserId,
          reason: reason);

  Future<MatchDto> issueCard(int matchId, int playerId, String cardType) =>
      _matchService.issueCard(matchId, playerId, cardType);

  Future<MatchDto> revokeCard(int matchId, int cardId) =>
      _matchService.revokeCard(matchId, cardId);
}
