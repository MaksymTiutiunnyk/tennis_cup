import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/page_request.dart';
import 'package:tennis_cup/data/models/page_result.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/services/abstract/i_tournament_service.dart';
import 'package:tennis_cup/data/services/dto/tournament_dto.dart';

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
}
