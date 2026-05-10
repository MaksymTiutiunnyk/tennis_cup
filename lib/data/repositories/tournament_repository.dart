import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/models/match_view.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/models/tournament_request.dart';
import 'package:tennis_cup/data/models/winner_view.dart';
import 'package:tennis_cup/data/services/abstract/i_arena_service.dart';
import 'package:tennis_cup/data/services/abstract/i_match_service.dart';
import 'package:tennis_cup/data/services/abstract/i_player_service.dart';
import 'package:tennis_cup/data/services/abstract/i_tournament_service.dart';
import 'package:tennis_cup/data/services/dto/arena_dto.dart';
import 'package:tennis_cup/data/services/dto/dashboard_dto.dart';
import 'package:tennis_cup/data/services/dto/match_dto.dart';
import 'package:tennis_cup/data/services/dto/tournament_dto.dart';

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
    required List<String> statuses,
  }) async {
    final dtos = await _service.fetchScheduledTournaments(
      date: tournamentDate,
      arena: tournamentArena,
      time: tournamentTime,
      statuses: statuses,
    );
    return _buildTournaments(dtos);
  }

  Future<List<MatchView>> fetchLiveStreamMatches() async {
    final dtos = await _service.fetchCurrentMatches();
    if (dtos.isEmpty) return const [];
    final arenaMap = await _fetchArenaMap({for (final d in dtos) d.arena.id});
    return dtos.map((dto) => _matchViewFromDto(dto, arenaMap)).toList();
  }

  Future<List<MatchView>> fetchUpcomingMatches() async {
    final dtos = await _service.fetchDashboardUpcomingMatches();
    if (dtos.isEmpty) return const [];
    final arenaMap = await _fetchArenaMap({for (final d in dtos) d.arena.id});
    return dtos.map((dto) => _matchViewFromDto(dto, arenaMap)).toList();
  }

  Future<Map<int, ArenaDto>> _fetchArenaMap(Set<int> arenaIds) async {
    final entries = await Future.wait(arenaIds.map((id) async {
      try {
        final arena = await _arenaService.fetchArenaById(id);
        return MapEntry(id, arena);
      } catch (_) {
        return MapEntry(id, ArenaDto(id: id, name: '', color: ''));
      }
    }));
    return Map.fromEntries(entries);
  }

  Future<List<WinnerView>> fetchWinners() async {
    final dtos = await _service.fetchLastWinners();
    return dtos
        .where((d) => d.tournament != null && d.winners?.isNotEmpty == true)
        .map(_winnerViewFromDto)
        .toList();
  }

  static MatchView _matchViewFromDto(
    ArenaMatchViewDto dto,
    Map<int, ArenaDto> arenaMap,
  ) {
    final arenaDto = arenaMap[dto.arena.id] ??
        ArenaDto(id: dto.arena.id, name: dto.arena.name, color: '');
    return MatchView(
      matchId: dto.matchId.toString(),
      arenaId: dto.arena.id.toString(),
      arenaName: dto.arena.name,
      arenaColor: arenaColorFromString(arenaDto.color),
      tournamentId: dto.tournament.id.toString(),
      tournamentGender: dto.tournament.gender,
      tournamentTime: timeFromString(dto.tournament.type),
      tournamentStart: DateTime.parse(dto.tournament.start),
      bluePlayer: _playerFromBrief(dto.bluePlayer),
      redPlayer: _playerFromBrief(dto.redPlayer),
      blueScore: dto.score.blueSets,
      redScore: dto.score.redSets,
    );
  }

  static WinnerView _winnerViewFromDto(ArenaLastWinnerDto dto) => WinnerView(
        arenaName: dto.arena.name,
        tournamentId: dto.tournament!.id.toString(),
        tournamentName: dto.tournament!.name,
        tournamentGender: dto.tournament!.gender,
        tournamentTime: timeFromString(dto.tournament!.type),
        tournamentStart: DateTime.parse(dto.tournament!.start),
        winners: dto.winners!.map(_playerFromBrief).toList(),
      );

  static Player _playerFromBrief(PlayerBriefDto dto) => Player(
        userId: dto.id,
        name: dto.firstName,
        surname: dto.lastName,
        sex: Sex.All,
        imageUrl: dto.avatarUrl ?? '',
        tournaments: 0,
        matches: 0,
        wins: 0,
        loses: 0,
        gold: 0,
        silver: 0,
        bronze: 0,
        rankTennis: 0.0,
        rankUTTF: 0.0,
      );

  Stream<void> watchTournamentChanges(String tournamentId) {
    return _service.watchTournamentChanges(tournamentId);
  }

  Future<PageResult<Tournament>> fetchPlayersTournaments({
    required String userId,
    required PageRequest page,
  }) async {
    final result = await _service.fetchPlayerTournaments(
      userId: userId,
      page: page,
    );
    final tournaments = await _buildTournaments(result.items);
    return PageResult(items: tournaments, hasMore: result.hasMore);
  }

  Future<Tournament> fetchTournamentById({
    required String tournamentId,
    bool withPlayers = true,
    bool withMatches = true,
  }) async {
    final dto = await _service.fetchTournamentById(tournamentId);
    final results = await _buildTournaments(
      [dto],
      withPlayers: withPlayers,
      withMatches: withMatches,
    );
    return results.first;
  }

  // ---- Management ----

  Future<void> createTournament(CreateTournamentRequest request) async {
    await _service.createTournament(CreateTournamentRequestDto(
      name: request.name,
      type: request.type,
      gender: request.gender,
      startTime: request.startTime.toUtc().toIso8601String(),
      arenaId: request.arenaId,
      refereeIds: request.refereeIds,
      matchDurationMinutes: request.matchDurationMinutes,
      requiredPlayersCount: request.requiredPlayersCount,
      setsToWin: request.setsToWin,
      playerIds: request.playerIds,
    ));
  }

  Future<void> updateTournament(int id, UpdateTournamentRequest request) async {
    await _service.updateTournament(
      id,
      UpdateTournamentRequestDto(
        name: request.name,
        type: request.type,
        gender: request.gender,
        startTime: request.startTime?.toUtc().toIso8601String(),
        arenaId: request.arenaId,
        refereeIds: request.refereeIds,
        playerIds: request.playerIds,
      ),
    );
  }

  Future<void> deleteTournament(int id) => _service.deleteTournament(id);

  Future<void> addPlayers(int tournamentId, List<int> playerIds) async {
    await _service.addPlayers(tournamentId, playerIds);
  }

  Future<void> removePlayers(int tournamentId, List<int> playerIds) async {
    await _service.removePlayers(tournamentId, playerIds);
  }

  Future<void> startTournament(int id) async {
    await _service.startTournament(id);
  }

  Future<void> finishTournament(int id) async {
    await _service.finishTournament(id);
  }

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
        neededPlayerIds.addAll(dto.participants.map((p) => p.playerId));
      }
    }
    for (final matches in matchDtosByTournament.values) {
      for (final m in matches) {
        if (m.bluePlayerId != null) neededPlayerIds.add(m.bluePlayerId!);
        if (m.redPlayerId != null) neededPlayerIds.add(m.redPlayerId!);
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
      final places = <int>[];
      if (withPlayers) {
        for (final participant in dto.participants) {
          final p = playerMap[participant.playerId];
          if (p == null) continue;
          players.add(p);
          if (withMatches) points.add(pointsById[participant.playerId] ?? 0);
          if (dto.status == 'FINISHED') places.add(participant.place ?? 0);
        }
      }

      final matches =
          withMatches ? _buildMatches(tournamentMatchDtos, playerMap) : null;

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

  static Map<int, int> _computePointsById(List<MatchDto> matches) {
    final pointsByPlayer = <int, int>{};
    for (final match in matches) {
      final winner = match.winnerId;
      if (winner == null) continue;
      if (match.bluePlayerId == null || match.redPlayerId == null) continue;
      final loser = winner == match.bluePlayerId
          ? match.redPlayerId!
          : match.bluePlayerId!;
      pointsByPlayer.update(winner, (v) => v + 2, ifAbsent: () => 2);
      pointsByPlayer.update(loser, (v) => v + 1, ifAbsent: () => 1);
    }
    return pointsByPlayer;
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
        final p = await _playerService.fetchPlayerById(id);
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
      name: dto.name,
      gender: dto.gender,
      status: dto.status,
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
      refereeId: dto.refereeId,
      setsToWin: dto.setsToWin,
      requiredPlayersCount: dto.requiredPlayersCount,
      participantInvitations: dto.participants
          .map((p) => TournamentParticipant(
              playerId: p.playerId, status: p.invitationStatus))
          .toList(),
      refereeInvitations: dto.refereeInvitations
          .map((r) => TournamentRefereeInvitation(
              refereeId: r.refereeId, status: r.status))
          .toList(),
    );
  }
}
