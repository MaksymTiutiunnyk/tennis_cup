import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/services/abstract/i_match_service.dart';
import 'package:tennis_cup/data/services/abstract/i_player_service.dart';
import 'package:tennis_cup/data/services/dto/match_dto.dart';

class MatchRepository {
  final IMatchService _service;
  final IPlayerService _playerService;

  const MatchRepository(this._service, this._playerService);

  Future<Match?> fetchMatchById({required String matchId}) async {
    final dto = await _service.fetchMatchById(matchId);
    if (dto == null) return null;
    final players = await _fetchPlayers({dto.bluePlayerId, dto.redPlayerId});
    return _toMatch(dto, players);
  }

  Future<PageResult<Match>> fetchPlayersMatches({
    required String player1Id,
    String? player2Id,
    required PageRequest page,
  }) async {
    final result = await _service.fetchPlayersMatches(
      playerId: player1Id,
      player2Id: player2Id,
      page: page,
    );
    final ids = <int>{};
    for (final dto in result.items) {
      ids.add(dto.bluePlayerId);
      ids.add(dto.redPlayerId);
    }
    final players = await _fetchPlayers(ids);
    final matches = result.items
        .map((dto) => _toMatch(dto, players))
        .whereType<Match>()
        .toList();
    return PageResult(items: matches, hasMore: result.hasMore);
  }

  Future<PageResult<Match>> fetchHeadToHead({
    required int player1Id,
    required int player2Id,
    required PageRequest page,
  }) async {
    final resultFuture = _service.fetchHeadToHead(
      player1Id: player1Id,
      player2Id: player2Id,
      page: page,
    );
    final p1Future = _playerService.fetchPlayerById(player1Id.toString());
    final p2Future = _playerService.fetchPlayerById(player2Id.toString());

    final result = await resultFuture;
    final player1 = await p1Future;
    final player2 = await p2Future;

    final matches = result.items.map((dto) {
      final sortedSets = [...dto.sets]
        ..sort((a, b) => a.setNumber.compareTo(b.setNumber));
      return Match(
        matchId: dto.matchId.toString(),
        bluePlayer: player1,
        redPlayer: player2,
        blueScore: dto.player1SetsWon,
        redScore: dto.player2SetsWon,
        blueSetScores: sortedSets.map((s) => s.player1Score).toList(),
        redSetScores: sortedSets.map((s) => s.player2Score).toList(),
        tournamentId: dto.tournamentId.toString(),
        dateTime: dto.matchDate,
      );
    }).toList();

    return PageResult(items: matches, hasMore: result.hasMore);
  }

  Stream<void> watchMatchChanges(String matchId) {
    return _service.watchMatchChanges(matchId);
  }

  Future<Map<int, Player>> _fetchPlayers(Set<int> ids) async {
    if (ids.isEmpty) return const {};
    final entries = await Future.wait(ids.map((id) async {
      try {
        final p = await _playerService.fetchPlayerById(id.toString());
        return MapEntry<int, Player?>(id, p);
      } catch (_) {
        return MapEntry<int, Player?>(id, null);
      }
    }));
    return {
      for (final e in entries)
        if (e.value != null) e.key: e.value!,
    };
  }

  static Match? _toMatch(MatchDto dto, Map<int, Player> players) {
    final blue = players[dto.bluePlayerId];
    final red = players[dto.redPlayerId];
    if (blue == null || red == null) return null;
    final sortedSets = [...dto.sets]
      ..sort((a, b) => a.number.compareTo(b.number));
    return Match(
      matchId: dto.id.toString(),
      bluePlayer: blue,
      redPlayer: red,
      blueScore: sortedSets.where((s) => s.winnerId == dto.bluePlayerId).length,
      redScore: sortedSets.where((s) => s.winnerId == dto.redPlayerId).length,
      blueSetScores: sortedSets.map((s) => s.bluePlayerScore).toList(),
      redSetScores: sortedSets.map((s) => s.redPlayerScore).toList(),
      tournamentId: dto.tournamentId.toString(),
      dateTime: DateTime.parse(dto.scheduledStart),
    );
  }
}
