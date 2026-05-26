import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/core/utils/enum_utils.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/arena_winner.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/models/tournament_request.dart';
import 'package:tennis_cup/data/models/user.dart';
import 'package:tennis_cup/data/repositories/player_repository.dart';
import 'package:tennis_cup/data/services/abstract/i_arena_service.dart';
import 'package:tennis_cup/data/services/abstract/i_match_service.dart';
import 'package:tennis_cup/data/services/abstract/i_tournament_service.dart';
import 'package:tennis_cup/data/services/dto/arena_dto.dart';
import 'package:tennis_cup/data/services/dto/dashboard_dto.dart';
import 'package:tennis_cup/data/services/dto/match_dto.dart';
import 'package:tennis_cup/data/services/dto/tournament_dto.dart';

class TournamentRepository {
  final ITournamentService _service;
  final IArenaService _arenaService;
  final PlayerRepository _playerRepository;
  final IMatchService _matchService;

  const TournamentRepository(
    this._service,
    this._arenaService,
    this._playerRepository,
    this._matchService,
  );

  Future<List<Tournament>> fetchScheduledTournament({
    required DateTime tournamentDate,
    required Arena tournamentArena,
    required Time tournamentTime,
    required List<String> statuses,
  }) async {
    // tournamentDate is a local calendar day from the date picker.
    // Convert to UTC day boundaries so the backend (UTC date-time filter)
    // returns exactly the tournaments the user sees as "today".
    final dayStart = DateTime(tournamentDate.year, tournamentDate.month, tournamentDate.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final dtos = await _service.fetchScheduledTournaments(
      startTime: dayStart.toUtc(),
      endTime: dayEnd.toUtc(),
      arena: tournamentArena,
      time: tournamentTime,
      statuses: statuses,
    );
    return _buildTournaments(dtos);
  }

  Future<List<Match>> fetchLiveStreamMatches() async {
    final dtos = await _service.fetchCurrentMatches();
    if (dtos.isEmpty) return const [];
    final arenaMap = await _fetchArenaMap({for (final d in dtos) d.arena.id});
    return dtos.map((dto) => _matchFromDashboardDto(dto, arenaMap)).toList();
  }

  Future<List<Match>> fetchUpcomingMatches() async {
    final dtos = await _service.fetchDashboardUpcomingMatches();
    if (dtos.isEmpty) return const [];
    final arenaMap = await _fetchArenaMap({for (final d in dtos) d.arena.id});
    return dtos.map((dto) => _matchFromDashboardDto(dto, arenaMap)).toList();
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

  Future<List<ArenaWinner>> fetchWinners() async {
    final dtos = await _service.fetchLastWinners();
    return dtos
        .where((d) => d.tournament != null && d.winners?.isNotEmpty == true)
        .map(_winnerViewFromDto)
        .toList();
  }

  static Match _matchFromDashboardDto(
    ArenaMatchViewDto dto,
    Map<int, ArenaDto> arenaMap,
  ) {
    final arenaDto = arenaMap[dto.arena.id] ??
        ArenaDto(id: dto.arena.id, name: dto.arena.name, color: '');
    final bluePlayer = _playerFromBrief(dto.bluePlayer);
    final redPlayer = _playerFromBrief(dto.redPlayer);
    final sets = <MatchSet>[
      for (int i = 0; i < dto.score.blueSets; i++)
        MatchSet(
          id: 0,
          matchId: dto.matchId,
          number: i + 1,
          blueScore: 11,
          redScore: 0,
          status: SetStatus.finished,
          winnerId: dto.bluePlayer.id,
        ),
      for (int i = 0; i < dto.score.redSets; i++)
        MatchSet(
          id: 0,
          matchId: dto.matchId,
          number: dto.score.blueSets + i + 1,
          blueScore: 0,
          redScore: 11,
          status: SetStatus.finished,
          winnerId: dto.redPlayer.id,
        ),
    ];
    return Match(
      id: dto.matchId,
      arenaId: dto.arena.id.toString(),
      arenaName: dto.arena.name,
      arenaColor: arenaColorFromString(arenaDto.color),
      tournamentId: dto.tournament.id,
      tournamentGender: dto.tournament.gender,
      tournamentTime: timeFromString(dto.tournament.type),
      scheduledStart: DateTime.parse(dto.tournament.start).toLocal(),
      bluePlayer: bluePlayer,
      redPlayer: redPlayer,
      sets: sets,
      youTubeUrl: dto.tournament.youTubeUrl,
    );
  }

  static ArenaWinner _winnerViewFromDto(ArenaLastWinnerDto dto) => ArenaWinner(
        arenaName: dto.arena.name,
        arenaColor: ArenaColor.grey,
        tournamentId: dto.tournament!.id,
        tournamentName: dto.tournament!.name,
        tournamentGender: dto.tournament!.gender,
        tournamentTime: timeFromString(dto.tournament!.type),
        tournamentStart: DateTime.parse(dto.tournament!.start).toLocal(),
        winners: dto.winners!.map(_playerFromBrief).toList(),
      );

  static User _playerFromBrief(PlayerBriefDto dto) => User(
        id: dto.id,
        firstName: dto.firstName,
        lastName: dto.lastName,
        imageUrl: dto.avatarUrl ?? '',
      );

  Stream<void> watchTournamentChanges(String tournamentId) {
    return _service.watchTournamentChanges(tournamentId);
  }

  Future<PageResult<Tournament>> fetchPlayerTournaments({
    required String playerId,
    required PageRequest page,
  }) async {
    final result = await _service.fetchPlayerTournaments(
        userId: playerId,
        page: page,
        statuses: ['ACTIVE', 'FINISHED'],
        sortDirection: 'DESC');
    final tournaments = await _buildTournaments(result.items);
    return PageResult(items: tournaments, hasMore: result.hasMore);
  }

  Future<List<Tournament>> fetchMyTournamentsAsPlayer(String userId) async {
    final myId = int.tryParse(userId) ?? -1;
    final result = await _service.fetchPlayerTournaments(
        userId: myId.toString(),
        page: const PageRequest(page: 0, size: 100),
        statuses: const ['PENDING', 'ACTIVE'],
        sortDirection: 'ASC');
    final dtos = result.items
        .where((dto) => dto.participants.any((p) =>
            p.userId == myId &&
            p.role == 'PLAYER' &&
            p.invitationStatus == 'ACCEPTED'))
        .toList();
    return _buildTournaments(dtos, withMatches: false);
  }

  Future<List<Tournament>> fetchMyTournamentsAsReferee(String userId) async {
    final myId = int.tryParse(userId) ?? -1;
    final result = await _service.fetchRefereeTournaments(
      page: const PageRequest(page: 0, size: 100),
      refereeId: myId.toString(),
      statuses: const ['PENDING', 'ACTIVE'],
    );
    final dtos = result.items.where((dto) => dto.refereeId == myId).toList();
    return _buildTournaments(dtos, withMatches: false);
  }

  Future<Tournament> fetchTournamentById({
    required String tournamentId,
    bool withUsers = true,
    bool withMatches = true,
  }) async {
    final dto = await _service.fetchTournamentById(tournamentId);
    final results = await _buildTournaments(
      [dto],
      withPlayers: withUsers,
      withMatches: withMatches,
    );
    return results.first;
  }

  // ---- Management ----

  Future<void> createTournament(CreateUpdateTournamentRequest request) async {
    await _service.createTournament(CreateUpdateTournamentRequestDto(
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
      youTubeUrl: request.youTubeUrl,
    ));
  }

  Future<void> updateTournament(
      int id, CreateUpdateTournamentRequest request) async {
    await _service.updateTournament(
      id,
      CreateUpdateTournamentRequestDto(
        name: request.name,
        type: request.type,
        gender: request.gender,
        startTime: request.startTime.toUtc().toIso8601String(),
        arenaId: request.arenaId,
        matchDurationMinutes: request.matchDurationMinutes,
        requiredPlayersCount: request.requiredPlayersCount,
        setsToWin: request.setsToWin,
        refereeIds: request.refereeIds,
        playerIds: request.playerIds,
        youTubeUrl: request.youTubeUrl,
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
        neededPlayerIds.addAll(dto.participants
            .where((p) => p.role == 'PLAYER')
            .map((p) => p.userId));
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

      final players = <User>[];
      final points = <int>[];
      final places = <int>[];
      if (withPlayers) {
        for (final participant in dto.participants) {
          if (participant.role != 'PLAYER') continue;
          final p = playerMap[participant.userId];
          if (p == null) continue;
          if (participant.invitationStatus != 'ACCEPTED') continue;
          players.add(p);
          if (withMatches) points.add(pointsById[participant.userId] ?? 0);
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

  Future<Map<int, User>> _fetchPlayers(Set<int> ids) =>
      _playerRepository.fetchUsersBatch(ids);

  static List<Match> _buildMatches(
    List<MatchDto> dtos,
    Map<int, User> players,
  ) {
    final matches = <Match>[];
    for (final dto in dtos) {
      final blue = players[dto.bluePlayerId];
      final red = players[dto.redPlayerId];
      if (blue == null || red == null) continue;
      final sortedSets = [...dto.sets]
        ..sort((a, b) => a.number.compareTo(b.number));
      matches.add(Match(
        id: dto.id,
        bluePlayer: blue,
        redPlayer: red,
        tournamentId: dto.tournamentId,
        scheduledStart: DateTime.parse(dto.scheduledStart).toLocal(),
        status:
            enumFromString(MatchStatus.values, dto.status, MatchStatus.pending),
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
      ));
    }
    return matches;
  }

  static Tournament _toTournament(
    TournamentDto dto,
    List<ArenaDto> arenaDtos, {
    List<User> players = const [],
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
      status: enumFromString(
          TournamentStatus.values, dto.status, TournamentStatus.pending),
      date: DateTime.parse(dto.startTime).toLocal(),
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
      matchDurationMinutes: dto.matchDurationMinutes,
      requiredPlayersCount: dto.requiredPlayersCount,
      youTubeUrl: dto.youTubeUrl,
      participantInvitations: dto.participants
          .where((p) => p.role == 'PLAYER')
          .map((p) => TournamentParticipant(
              playerId: p.userId, status: p.invitationStatus))
          .toList(),
      refereeInvitations: dto.participants
          .where((p) => p.role == 'REFEREE')
          .map((p) => TournamentRefereeInvitation(
              refereeId: p.userId, status: p.invitationStatus))
          .toList(),
    );
  }
}
