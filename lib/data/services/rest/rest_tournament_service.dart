import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/services/abstract/i_tournament_service.dart';
import 'package:tennis_cup/data/services/dto/tournament_dto.dart';
import 'package:tennis_cup/data/services/dto/tournament_invitation_dto.dart';

final _dateFormat = DateFormat('yyyy-MM-dd');

class RestTournamentService implements ITournamentService {
  final Dio _dio;

  const RestTournamentService(this._dio);

  @override
  Future<PageResult<TournamentDto>> fetchPlayerTournaments({
    required String playerId,
    String? player2Id,
    required PageRequest page,
  }) async {
    final response = await _dio.get('/api/v1/tournaments', queryParameters: {
      // 'page': page.page,
      // 'size': page.size,
      // TODO: to be commented in
    });

    final body = response.data as Map<String, dynamic>;
    final content = body['content'] as List<dynamic>;
    final totalPages = body['totalPages'] as int? ?? 1;

    final dtos = <TournamentDto>[];
    for (final json in content) {
      final dto = TournamentDto.fromJson(json as Map<String, dynamic>);
      if (!dto.playerIds.map((id) => id.toString()).contains(playerId)) {
        continue;
      }
      if (player2Id != null &&
          !dto.playerIds.map((id) => id.toString()).contains(player2Id)) {
        continue;
      }
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
  }) async {
    final queryParams = <String, dynamic>{
      'start': _dateFormat.format(date),
    };
    if (arena.id != null) queryParams['arenaId'] = arena.id;

    final response =
        await _dio.get('/api/v1/tournaments', queryParameters: queryParams);
    final body = response.data as Map<String, dynamic>;
    final content = body['content'] as List<dynamic>;

    return content
        .map((json) => TournamentDto.fromJson(json as Map<String, dynamic>))
        .where((dto) => timeFromString(dto.type) == time)
        .toList();
  }

  @override
  Future<List<TournamentDto>> fetchRecentTournaments({int limit = 10}) async {
    final response = await _dio.get('/api/v1/tournaments', queryParameters: {
      'status': 'FINISHED',
      'size': limit,
      'sortDirection': 'DESC',
    });
    final body = response.data as Map<String, dynamic>;
    final content = body['content'] as List<dynamic>;
    return content
        .map((json) => TournamentDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<TournamentDto>> fetchUpcomingTournaments({int limit = 10}) async {
    final response = await _dio.get('/api/v1/tournaments', queryParameters: {
      'status': 'PENDING',
      'size': limit,
      'sortDirection': 'ASC',
    });
    final body = response.data as Map<String, dynamic>;
    final content = body['content'] as List<dynamic>;
    return content
        .map((json) => TournamentDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Stream<void> watchTournamentChanges(String tournamentId) =>
      const Stream.empty();

  // TODO: replace stub with real call to tournament-service invitations
  // endpoint when the backend exposes it (e.g. GET /api/v1/invitations).
  @override
  Future<List<TournamentInvitationDto>> fetchInvitations({
    required String playerId,
  }) async {
    return _stubInvitations
        .where((dto) => dto.playerId.toString() == playerId)
        .toList();
  }

  // TODO: replace with POST /api/v1/invitations/{id}/accept once available.
  @override
  Future<void> acceptInvitation(String invitationId) async {}

  // TODO: replace with POST /api/v1/invitations/{id}/decline once available.
  @override
  Future<void> declineInvitation(String invitationId) async {}

  static const _stubPlayerId = 1;
  // TODO: tournamentIds reference real tournaments in the dev backend so the
  // repository's fetchTournamentById call resolves. Drop this stub once the
  // invitations endpoint exists.
  static const List<TournamentInvitationDto> _stubInvitations = [
    TournamentInvitationDto(
      id: 1,
      tournamentId: 47,
      playerId: _stubPlayerId,
      playerNumber: 3,
      startTime: '2026-05-12T09:00:00',
      endTime: '2026-05-12T12:30:00',
      deadline: '2026-05-08T23:59:59',
      status: 'PENDING',
    ),
    TournamentInvitationDto(
      id: 2,
      tournamentId: 68,
      playerId: _stubPlayerId,
      playerNumber: 1,
      startTime: '2026-05-18T18:00:00',
      endTime: '2026-05-18T21:00:00',
      deadline: '2026-05-15T23:59:59',
      status: 'PENDING',
    ),
    TournamentInvitationDto(
      id: 3,
      tournamentId: 48,
      playerId: _stubPlayerId,
      playerNumber: 7,
      startTime: '2026-06-02T13:30:00',
      endTime: '2026-06-02T17:00:00',
      deadline: '2026-05-30T23:59:59',
      status: 'PENDING',
    ),
    TournamentInvitationDto(
      id: 4,
      tournamentId: 83,
      playerId: _stubPlayerId,
      playerNumber: 5,
      startTime: '2026-06-14T20:00:00',
      endTime: '2026-06-14T23:30:00',
      deadline: '2026-06-10T23:59:59',
      status: 'PENDING',
    ),
  ];
}
