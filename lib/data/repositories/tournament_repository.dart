import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/page_request.dart';
import 'package:tennis_cup/data/models/page_result.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/services/abstract/i_arena_service.dart';
import 'package:tennis_cup/data/services/abstract/i_tournament_service.dart';
import 'package:tennis_cup/data/services/dto/arena_dto.dart';
import 'package:tennis_cup/data/services/dto/tournament_dto.dart';

class TournamentRepository {
  final ITournamentService _service;
  final IArenaService _arenaService;

  const TournamentRepository(this._service, this._arenaService);

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
    return _enrichWithArenas(dtos);
  }

  Future<List<Tournament>> fetchLiveStreamMatchesTournaments() async {
    final dtos = await _service.fetchRecentTournaments();
    return _enrichWithArenas(dtos);
  }

  Future<List<Tournament>> fetchUpcomingMatchesTournaments() async {
    final dtos = await _service.fetchUpcomingTournaments();
    return _enrichWithArenas(dtos);
  }

  Future<List<Tournament>> fetchWinnersTournaments() async {
    final dtos = await _service.fetchRecentTournaments();
    return _enrichWithArenas(dtos);
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
    final tournaments = await _enrichWithArenas(result.items);
    return PageResult(items: tournaments, hasMore: result.hasMore);
  }

  Future<Tournament> fetchTournamentById({required String tournamentId}) async {
    final dto = await _service.fetchTournamentById(tournamentId);
    final arenaDtos = await _arenaService.fetchAllArenas();
    return _toTournament(dto, arenaDtos);
  }

  Future<List<Tournament>> _enrichWithArenas(List<TournamentDto> dtos) async {
    if (dtos.isEmpty) return const [];
    final arenaDtos = await _arenaService.fetchAllArenas();
    return dtos.map((dto) => _toTournament(dto, arenaDtos)).toList();
  }

  static Tournament _toTournament(TournamentDto dto, List<ArenaDto> arenaDtos) {
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
      players: const [],
      arena: Arena(
        id: arenaDto.id.toString(),
        title: arenaDto.name,
        color: arenaColorFromString(arenaDto.color),
        city: arenaDto.city,
      ),
      time: timeFromString(dto.type),
      points: const [],
      places: const [],
      isFinished: dto.status == 'FINISHED',
      matches: null,
    );
  }

}
