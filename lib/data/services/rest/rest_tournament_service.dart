import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/services/abstract/i_tournament_service.dart';
import 'package:tennis_cup/data/services/dto/dashboard_dto.dart';
import 'package:tennis_cup/data/services/dto/tournament_dto.dart';
import 'package:tennis_cup/data/services/dto/tournament_invitation_dto.dart';

final _dateFormat = DateFormat('yyyy-MM-dd');

class RestTournamentService implements ITournamentService {
  final Dio _dio;

  const RestTournamentService(this._dio);

  @override
  Future<PageResult<TournamentDto>> fetchPlayerTournaments({
    required String userId,
    required PageRequest page,
    required List<String> statuses,
  }) async {
    final response = await _dio.get('/api/v1/tournaments', queryParameters: {
      'page': page.page,
      'size': page.size,
      'playerId': userId,
      'statuses': statuses
    });

    final body = response.data as Map<String, dynamic>;
    final content = body['content'] as List<dynamic>;
    final totalPages = body['totalPages'] as int? ?? 1;

    final dtos = <TournamentDto>[];
    for (final json in content) {
      final dto = TournamentDto.fromJson(json as Map<String, dynamic>);
      dtos.add(dto);
    }

    return PageResult(
      items: dtos,
      hasMore: page.page + 1 < totalPages,
    );
  }

  @override
  Future<TournamentDto> fetchTournamentById(String id) async {
    final response = await _dio.get('/api/v1/tournaments/$id');
    return TournamentDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<TournamentDto>> fetchScheduledTournaments({
    required DateTime date,
    required Arena arena,
    required Time time,
    required List<String> statuses,
  }) async {
    final queryParams = <String, dynamic>{
      'start': _dateFormat.format(date),
      'type': time.name.toUpperCase(),
      'statuses': statuses,
    };
    if (arena.id.isNotEmpty) queryParams['arenaId'] = arena.id;

    final response =
        await _dio.get('/api/v1/tournaments', queryParameters: queryParams);
    final body = response.data as Map<String, dynamic>;
    final content = body['content'] as List<dynamic>;

    return content
        .map((json) => TournamentDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ArenaMatchViewDto>> fetchCurrentMatches() async {
    final response = await _dio
        .get<List<dynamic>>('/api/v1/dashboard/arenas/current-matches');
    return (response.data ?? [])
        .map((e) => ArenaMatchViewDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ArenaMatchViewDto>> fetchDashboardUpcomingMatches() async {
    final response = await _dio
        .get<List<dynamic>>('/api/v1/dashboard/tournaments/upcoming-matches');
    return (response.data ?? [])
        .map((e) => ArenaMatchViewDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ArenaLastWinnerDto>> fetchLastWinners() async {
    final response =
        await _dio.get<List<dynamic>>('/api/v1/dashboard/arenas/last-winners');
    return (response.data ?? [])
        .map((e) => ArenaLastWinnerDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PageResult<TournamentDto>> fetchActiveTournamentsForReferee(
    PageRequest page,
    String refereeId,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/tournaments',
      queryParameters: {
        'page': page.page,
        'size': page.size,
        'refereeId': refereeId,
        'statuses': ['ACTIVE']
      },
    );
    final body = response.data!;
    final content = (body['content'] as List<dynamic>)
        .map((e) => TournamentDto.fromJson(e as Map<String, dynamic>))
        .toList();
    final totalPages = (body['totalPages'] as num?)?.toInt() ?? 1;
    return PageResult(items: content, hasMore: page.page + 1 < totalPages);
  }

  @override
  Stream<void> watchTournamentChanges(String tournamentId) =>
      const Stream.empty();

  @override
  Future<List<MyInvitationDto>> fetchInvitations(
      {required String status}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/tournaments/my-invitations',
      queryParameters: {'status': status},
    );
    final content = (response.data!['content'] as List<dynamic>?) ?? [];
    return content
        .map((e) => MyInvitationDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> acceptInvitation(String tournamentId) async {
    await _dio
        .post<void>('/api/v1/tournaments/$tournamentId/invitations/accept');
  }

  @override
  Future<void> declineInvitation(String tournamentId) async {
    await _dio
        .post<void>('/api/v1/tournaments/$tournamentId/invitations/decline');
  }

  // ---- Write operations ----

  @override
  Future<TournamentDto> createTournament(CreateTournamentRequestDto dto) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/tournaments',
      data: dto.toJson(),
    );
    return TournamentDto.fromJson(response.data!);
  }

  @override
  Future<TournamentDto> updateTournament(
      int id, UpdateTournamentRequestDto dto) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/v1/tournaments/$id',
      data: dto.toJson(),
    );
    return TournamentDto.fromJson(response.data!);
  }

  @override
  Future<void> deleteTournament(int id) async {
    await _dio.delete<void>('/api/v1/tournaments/$id');
  }

  @override
  Future<TournamentDto> addPlayers(
      int tournamentId, List<int> playerIds) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/tournaments/$tournamentId/players',
      data: {'playerIds': playerIds},
    );
    return TournamentDto.fromJson(response.data!);
  }

  @override
  Future<TournamentDto> removePlayers(
      int tournamentId, List<int> playerIds) async {
    final response = await _dio.delete<Map<String, dynamic>>(
      '/api/v1/tournaments/$tournamentId/players',
      data: {'playerIds': playerIds},
    );
    return TournamentDto.fromJson(response.data!);
  }

  @override
  Future<TournamentDto> startTournament(int id) async {
    final response =
        await _dio.post<Map<String, dynamic>>('/api/v1/tournaments/$id/start');
    return TournamentDto.fromJson(response.data!);
  }

  @override
  Future<TournamentDto> finishTournament(int id) async {
    final response =
        await _dio.post<Map<String, dynamic>>('/api/v1/tournaments/$id/finish');
    return TournamentDto.fromJson(response.data!);
  }
}
