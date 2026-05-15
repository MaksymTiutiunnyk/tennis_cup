import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/core/utils/enum_utils.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/models/user.dart';
import 'package:tennis_cup/data/repositories/player_repository.dart';
import 'package:tennis_cup/data/services/abstract/i_match_service.dart';
import 'package:tennis_cup/data/services/dto/match_dto.dart';

class MatchRepository {
  final IMatchService _service;
  final PlayerRepository _playerRepository;

  const MatchRepository(this._service, this._playerRepository);

  Future<Match?> fetchMatchById({required String matchId}) async {
    final dto = await _service.fetchMatchById(matchId);
    if (dto == null) return null;
    final players = await _fetchPlayers({
      if (dto.bluePlayerId != null) dto.bluePlayerId!,
      if (dto.redPlayerId != null) dto.redPlayerId!
    });
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
      if (dto.bluePlayerId != null) ids.add(dto.bluePlayerId!);
      if (dto.redPlayerId != null) ids.add(dto.redPlayerId!);
    }
    final players = await _fetchPlayers(ids);
    final matches = result.items
        .map((dto) => _toMatch(dto, players))
        .whereType<Match>()
        .toList();
    return PageResult(items: matches, hasMore: result.hasMore);
  }

  Future<PageResult<Match>> fetchHeadToHead({
    required int playerId1,
    required int playerId2,
    required PageRequest page,
  }) async {
    final resultFuture = _service.fetchHeadToHead(
      userId1: playerId1,
      userId2: playerId2,
      page: page,
    );
    final p1Future = _playerRepository.fetchPlayerById(playerId1);
    final p2Future = _playerRepository.fetchPlayerById(playerId2);

    final result = await resultFuture;
    final player1 = await p1Future;
    final player2 = await p2Future;

    final matches = result.items.map((dto) {
      // Determine match status from DTO fields
      final matchStatus = dto.technicalDefeat
          ? MatchStatus.technicalDefeat
          : dto.winnerId != null
              ? MatchStatus.finished
              : MatchStatus.active;

      final sorted = [...dto.sets]
        ..sort((a, b) => a.setNumber.compareTo(b.setNumber));
      final sets = sorted.map((s) {
        // TODO: remove when backend returns set statuses
        int? winnerId;
        if ((s.player1Score >= 11 && s.player1Score - s.player2Score >= 2) ||
            (s.player2Score >= 11 && s.player2Score - s.player1Score >= 2)) {
          winnerId = s.player1Score > s.player2Score ? player1.id : player2.id;
        }
        return MatchSet(
          id: 0,
          matchId: dto.matchId,
          number: s.setNumber,
          blueScore: s.player1Score,
          redScore: s.player2Score,
          status:
              s.technicalDefeat ? SetStatus.technicalDefeat : SetStatus.pending,
          winnerId: winnerId,
        );
      }).toList();
      return Match(
        id: dto.matchId,
        bluePlayer: player1,
        redPlayer: player2,
        tournamentId: dto.tournamentId,
        scheduledStart: dto.matchDate,
        status: matchStatus,
        winnerId: dto.winnerId,
        sets: sets,
      );
    }).toList();

    return PageResult(items: matches, hasMore: result.hasMore);
  }

  Future<List<Match>> fetchMatchesForTournament(int tournamentId) async {
    final dtos = await _service.fetchTournamentMatches(tournamentId.toString());
    final ids = <int>{};
    for (final dto in dtos) {
      if (dto.bluePlayerId != null) ids.add(dto.bluePlayerId!);
      if (dto.redPlayerId != null) ids.add(dto.redPlayerId!);
    }
    final players = await _fetchPlayers(ids);
    return dtos
        .map((dto) => _toMatch(dto, players))
        .whereType<Match>()
        .toList();
  }

  Future<Match> fetchMatchWithPlayers(int matchId) async {
    final dto = await _service.fetchMatchById(matchId.toString());
    if (dto == null) throw Exception('Match $matchId not found');
    final players = await _fetchPlayers({
      if (dto.bluePlayerId != null) dto.bluePlayerId!,
      if (dto.redPlayerId != null) dto.redPlayerId!,
    });
    final match = _toMatch(dto, players);
    if (match == null) throw Exception('Match $matchId missing players');
    return match;
  }

  Future<Match> startMatch(int matchId, int firstServerId) async {
    final dto = await _service.startMatch(matchId, firstServerId);
    final players = await _fetchPlayers({
      if (dto.bluePlayerId != null) dto.bluePlayerId!,
      if (dto.redPlayerId != null) dto.redPlayerId!,
    });
    return _toMatch(dto, players) ??
        (throw Exception('startMatch: missing players'));
  }

  Future<void> finishMatch(int matchId) => _service.finishMatch(matchId);

  Future<void> startSet(int matchId, int setNumber) =>
      _service.startSet(matchId, setNumber);

  Future<void> updateScore(
          int matchId, int setNumber, int blueScore, int redScore) =>
      _service.updateScore(matchId, setNumber, blueScore, redScore);

  Future<void> finishSet(int matchId, int setNumber) =>
      _service.finishSet(matchId, setNumber);

  Future<void> technicalDefeatMatch(int matchId, int loserId,
          {String? reason}) =>
      _service.technicalDefeatMatch(matchId, loserId, reason: reason);

  Future<void> technicalDefeatSet(int matchId, int setNumber, int loserId,
          {String? reason}) =>
      _service.technicalDefeatSet(matchId, setNumber, loserId, reason: reason);

  Future<void> issueCard(int matchId, int playerId, String cardType) =>
      _service.issueCard(matchId, playerId, cardType);

  Future<void> revokeCard(int matchId, int cardId) =>
      _service.revokeCard(matchId, cardId);

  Stream<Match> watchMatchChanges(String matchId) {
    return _service
        .watchMatchChanges(matchId)
        .asyncMap((dto) async {
          final players = await _fetchPlayers({
            if (dto.bluePlayerId != null) dto.bluePlayerId!,
            if (dto.redPlayerId != null) dto.redPlayerId!,
          });
          return _toMatch(dto, players);
        })
        .where((m) => m != null)
        .cast<Match>();
  }

  Future<Map<int, User>> _fetchPlayers(Set<int> ids) async {
    if (ids.isEmpty) return const {};
    final entries = await Future.wait(ids.map((id) async {
      try {
        final p = await _playerRepository.fetchPlayerById(id);
        return MapEntry<int, User?>(id, p);
      } catch (_) {
        return MapEntry<int, User?>(id, null);
      }
    }));
    return {
      for (final e in entries)
        if (e.value != null) e.key: e.value!,
    };
  }

  static Match? _toMatch(MatchDto dto, Map<int, User> players) {
    final blue = players[dto.bluePlayerId];
    final red = players[dto.redPlayerId];
    if (blue == null || red == null) return null;
    final sortedSets = [...dto.sets]
      ..sort((a, b) => a.number.compareTo(b.number));
    return Match(
      id: dto.id,
      bluePlayer: blue,
      redPlayer: red,
      tournamentId: dto.tournamentId,
      scheduledStart: DateTime.parse(dto.scheduledStart),
      scheduledEnd:
          dto.scheduledEnd.isEmpty ? null : DateTime.tryParse(dto.scheduledEnd),
      actualStart:
          dto.actualStart != null ? DateTime.tryParse(dto.actualStart!) : null,
      actualEnd:
          dto.actualEnd != null ? DateTime.tryParse(dto.actualEnd!) : null,
      status:
          enumFromString(MatchStatus.values, dto.status, MatchStatus.pending),
      setsToWin: dto.setsToWin,
      refereeId: dto.refereeId,
      firstServerId: dto.firstServerId,
      winnerId: dto.winnerId,
      sets: sortedSets
          .map((s) => MatchSet(
                id: s.id,
                matchId: s.matchId,
                number: s.number,
                blueScore: s.bluePlayerScore,
                redScore: s.redPlayerScore,
                status: enumFromString(
                    SetStatus.values, s.status, SetStatus.pending),
                winnerId: s.winnerId,
              ))
          .toList(),
      cards: dto.cards
          .map((c) => MatchCard(
                id: c.id,
                matchId: c.matchId,
                playerId: c.playerId,
                cardType: c.cardType,
                issuedAt: DateTime.parse(c.issuedAt),
                setNumber: c.setNumber,
              ))
          .toList(),
    );
  }
}
