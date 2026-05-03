import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/services/abstract/i_arena_service.dart';
import 'package:tennis_cup/data/services/abstract/i_match_service.dart';
import 'package:tennis_cup/data/services/abstract/i_player_service.dart';
import 'package:tennis_cup/data/services/abstract/i_tournament_service.dart';
import 'package:tennis_cup/data/services/dto/arena_dto.dart';
import 'package:tennis_cup/data/services/dto/match_dto.dart';
import 'package:tennis_cup/data/services/dto/tournament_dto.dart';

export 'package:tennis_cup/data/services/dto/tournament_dto.dart'
    show TournamentDto, CreateTournamentRequestDto, UpdateTournamentRequestDto;

class TournamentRepository {
  final ITournamentService _service;
  final IArenaService _arenaService;
  final IPlayerService _playerService;
  final IMatchService _matchService;

  const TournamentRepository(
    this._service,
    this._arenaService,
    this._playerService,
    this._matchService,
  );

  Future<List<Tournament>> fetchScheduledTournament({
    required DateTime tournamentDate,
    required Arena tournamentArena,
    required Time tournamentTime,
  }) async {
    final dtos = await _service.fetchScheduledTournaments(
      date: tournamentDate,
      arena: tournamentArena,
      time: tournamentTime,
    );
    return _buildTournaments(dtos);
  }

  Future<List<Tournament>> fetchLiveStreamMatchesTournaments() async {
    final dtos = await _service.fetchRecentTournaments();
    return _buildTournaments(dtos);
  }

  Future<List<Tournament>> fetchUpcomingMatchesTournaments() async {
    final dtos = await _service.fetchUpcomingTournaments();
    return _buildTournaments(dtos);
  }

  Future<List<Tournament>> fetchWinnersTournaments() async {
    final dtos = await _service.fetchRecentTournaments();
    return _buildTournaments(dtos);
  }

  Stream<void> watchTournamentChanges(String tournamentId) {
    return _service.watchTournamentChanges(tournamentId);
  }

  Future<PageResult<Tournament>> fetchPlayersTournaments({
    required String player1Id,
    String? player2Id,
    required PageRequest page,
  }) async {
    final result = await _service.fetchPlayerTournaments(
      playerId: player1Id,
      player2Id: player2Id,
      page: page,
    );
    final tournaments = await _buildTournaments(result.items);
    return PageResult(items: tournaments, hasMore: result.hasMore);
  }

  Future<Tournament> fetchTournamentById({required String tournamentId}) async {
    final dto = await _service.fetchTournamentById(tournamentId);
    final results = await _buildTournaments([dto]);
    return results.first;
  }

  // ---- Management (lightweight — returns DTOs, no enrichment needed) ----

  Future<PageResult<TournamentDto>> fetchTournamentsPaged(
    PageRequest page, {
    String? status,
  }) =>
      _service.fetchTournamentsPaged(page, status: status);

  Future<TournamentDto> createTournament(CreateTournamentRequestDto dto) =>
      _service.createTournament(dto);

  Future<TournamentDto> updateTournament(
          int id, UpdateTournamentRequestDto dto) =>
      _service.updateTournament(id, dto);

  Future<void> deleteTournament(int id) => _service.deleteTournament(id);

  Future<TournamentDto> addPlayers(int tournamentId, List<int> playerIds) =>
      _service.addPlayers(tournamentId, playerIds);

  Future<TournamentDto> removePlayers(int tournamentId, List<int> playerIds) =>
      _service.removePlayers(tournamentId, playerIds);

  Future<TournamentDto> startTournament(int id) =>
      _service.startTournament(id);

  Future<TournamentDto> finishTournament(int id) =>
      _service.finishTournament(id);

  Future<List<Tournament>> _buildTournaments(
    List<TournamentDto> dtos, {
    bool withPlayers = true,
    bool withMatches = true,
  }) async {
    if (dtos.isEmpty) return const [];

    final arenaDtosF = _arenaService.fetchAllArenas();

    final matchDtosByTournament = withMatches
        ? await _fetchTournamentMatches(dtos)
        : const <int, List<MatchDto>>{};

    final neededPlayerIds = <int>{};
    if (withPlayers) {
      for (final dto in dtos) {
        neededPlayerIds.addAll(dto.playerIds);
      }
    }
    for (final matches in matchDtosByTournament.values) {
      for (final m in matches) {
        neededPlayerIds.add(m.bluePlayerId);
        neededPlayerIds.add(m.redPlayerId);
      }
    }

    final playerMap = await _fetchPlayers(neededPlayerIds);
    final arenaDtos = await arenaDtosF;

    return dtos.map((dto) {
      final tournamentMatchDtos = matchDtosByTournament[dto.id] ?? const [];
      final pointsById = withMatches
          ? _computePointsById(tournamentMatchDtos)
          : const <int, int>{};

      final players = <Player>[];
      final points = <int>[];
      if (withPlayers) {
        for (final id in dto.playerIds) {
          final p = playerMap[id];
          if (p == null) continue;
          players.add(p);
          if (withMatches) points.add(pointsById[id] ?? 0);
        }
      }

      final matches =
          withMatches ? _buildMatches(tournamentMatchDtos, playerMap) : null;
      final places = dto.status == 'FINISHED' && withMatches
          ? _computePlaces(points)
          : const <int>[];

      return _toTournament(
        dto,
        arenaDtos,
        players: players,
        matches: matches,
        points: points,
        places: places,
      );
    }).toList();
  }

  // TODO: Points and places are derived client-side until the backend exposes them.
  static Map<int, int> _computePointsById(List<MatchDto> matches) {
    final pointsByPlayer = <int, int>{};
    for (final match in matches) {
      final winner = match.winnerId;
      if (winner == null) continue;
      final loser =
          winner == match.bluePlayerId ? match.redPlayerId : match.bluePlayerId;
      pointsByPlayer.update(winner, (v) => v + 2, ifAbsent: () => 2);
      pointsByPlayer.update(loser, (v) => v + 1, ifAbsent: () => 1);
    }
    return pointsByPlayer;
  }

  static List<int> _computePlaces(List<int> points) {
    if (points.isEmpty) return const [];
    final ranked = List.generate(points.length, (i) => i)
      ..sort((a, b) => points[b].compareTo(points[a]));
    final places = List<int>.filled(points.length, 0);
    var currentPlace = 1;
    for (var i = 0; i < ranked.length; i++) {
      if (i > 0 && points[ranked[i]] != points[ranked[i - 1]]) {
        currentPlace = i + 1;
      }
      places[ranked[i]] = currentPlace;
    }
    return places;
  }

  Future<Map<int, List<MatchDto>>> _fetchTournamentMatches(
    List<TournamentDto> dtos,
  ) async {
    final entries = await Future.wait(dtos.map((dto) async {
      final matches =
          await _matchService.fetchTournamentMatches(dto.id.toString());
      return MapEntry(dto.id, matches);
    }));
    return Map.fromEntries(entries);
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

  static List<Match> _buildMatches(
    List<MatchDto> dtos,
    Map<int, Player> players,
  ) {
    final matches = <Match>[];
    for (final dto in dtos) {
      final blue = players[dto.bluePlayerId];
      final red = players[dto.redPlayerId];
      if (blue == null || red == null) continue;
      final sortedSets = [...dto.sets]
        ..sort((a, b) => a.number.compareTo(b.number));
      matches.add(Match(
        matchId: dto.id.toString(),
        bluePlayer: blue,
        redPlayer: red,
        blueScore:
            sortedSets.where((s) => s.winnerId == dto.bluePlayerId).length,
        redScore: sortedSets.where((s) => s.winnerId == dto.redPlayerId).length,
        blueSetScores: sortedSets.map((s) => s.bluePlayerScore).toList(),
        redSetScores: sortedSets.map((s) => s.redPlayerScore).toList(),
        tournamentId: dto.tournamentId.toString(),
        dateTime: DateTime.parse(dto.scheduledStart),
      ));
    }
    return matches;
  }

  static Tournament _toTournament(
    TournamentDto dto,
    List<ArenaDto> arenaDtos, {
    List<Player> players = const [],
    List<Match>? matches,
    List<int> points = const [],
    List<int> places = const [],
  }) {
    final arenaDto = arenaDtos.firstWhere(
      (a) => a.id == dto.arenaId,
      orElse: () => ArenaDto(
        id: dto.arenaId,
        name: dto.arenaId.toString(),
        color: '',
      ),
    );

    return Tournament(
      tournamentId: dto.id.toString(),
      date: DateTime.parse(dto.startTime),
      players: players,
      arena: Arena(
        id: arenaDto.id.toString(),
        title: arenaDto.name,
        color: arenaColorFromString(arenaDto.color),
        city: arenaDto.city,
      ),
      time: timeFromString(dto.type),
      points: points,
      places: places,
      isFinished: dto.status == 'FINISHED',
      matches: matches,
    );
  }
}
