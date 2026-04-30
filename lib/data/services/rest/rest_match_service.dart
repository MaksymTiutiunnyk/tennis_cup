import 'package:dio/dio.dart';
import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/data/services/abstract/i_match_service.dart';
import 'package:tennis_cup/data/services/dto/match_dto.dart';

class RestMatchService implements IMatchService {
  final Dio _dio;

  const RestMatchService(this._dio);

  @override
  Future<MatchDto?> fetchMatchById(String id) async {
    try {
      final response = await _dio.get('/api/v1/matches/$id');
      return MatchDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<List<MatchDto>> fetchTournamentMatches(String tournamentId) async {
    final response = await _dio.get('/api/v1/matches', queryParameters: {
      'tournamentId': tournamentId,
      'size': 100,
    });
    final body = response.data as Map<String, dynamic>;
    return (body['content'] as List<dynamic>)
        .map((json) => MatchDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Stream<void> watchMatchChanges(String matchId) => const Stream.empty();

  @override
  Future<PageResult<MatchDto>> fetchPlayersMatches({
    required String playerId,
    String? player2Id,
    required PageRequest page,
  }) async {
    final response = await _dio.get('/api/v1/matches', queryParameters: {
      'playerId': playerId,
      'page': page.page,
      'size': page.size,
    });
    final body = response.data as Map<String, dynamic>;
    final totalPages = body['totalPages'] as int? ?? 1;

    var dtos = (body['content'] as List<dynamic>)
        .map((json) => MatchDto.fromJson(json as Map<String, dynamic>))
        .toList();

    if (player2Id != null) {
      final p2 = int.tryParse(player2Id) ?? -1;
      dtos = dtos
          .where((dto) => dto.bluePlayerId == p2 || dto.redPlayerId == p2)
          .toList();
    }

    return PageResult(
      items: dtos,
      hasMore: page.page + 1 < totalPages,
    );
  }
}
