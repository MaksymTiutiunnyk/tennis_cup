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
  Future<PageResult<HeadToHeadMatchDto>> fetchHeadToHead({
    required int userId1,
    required int userId2,
    required PageRequest page,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/matches/head-to-head',
      queryParameters: {
        'player1Id': userId1,
        'player2Id': userId2,
        'page': page.page,
        'size': page.size,
      },
    );
    final body = response.data!;
    final content = (body['content'] as List<dynamic>)
        .map((e) => HeadToHeadMatchDto.fromJson(e as Map<String, dynamic>))
        .toList();
    final totalPages = (body['totalPages'] as num?)?.toInt() ?? 1;
    return PageResult(items: content, hasMore: page.page + 1 < totalPages);
  }

  @override
  Stream<void> watchMatchChanges(String matchId) => const Stream.empty();

  @override
  Future<MatchDto> startMatch(int matchId, int firstServerId) async {
    final response = await _dio.post('/api/v1/matches/$matchId/start', data: {
      'firstServerId': firstServerId,
    });
    return MatchDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MatchDto> finishMatch(int matchId) async {
    final response = await _dio.post('/api/v1/matches/$matchId/finish');
    return MatchDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MatchSetDto> startSet(int matchId, int setNumber) async {
    final response =
        await _dio.post('/api/v1/matches/$matchId/sets/$setNumber/start');
    return MatchSetDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MatchSetDto> updateScore(
      int matchId, int setNumber, int blueScore, int redScore) async {
    final response = await _dio.patch(
      '/api/v1/matches/$matchId/sets/$setNumber/score',
      data: {'bluePlayerScore': blueScore, 'redPlayerScore': redScore},
    );
    return MatchSetDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MatchSetDto> finishSet(int matchId, int setNumber) async {
    final response =
        await _dio.post('/api/v1/matches/$matchId/sets/$setNumber/finish');
    return MatchSetDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MatchDto> technicalDefeatMatch(int matchId, int loserId,
      {String? reason}) async {
    final response = await _dio.post(
      '/api/v1/matches/$matchId/technical-defeat',
      data: {
        'loserId': loserId,
        if (reason != null) 'reason': reason,
      },
    );
    return MatchDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MatchSetDto> technicalDefeatSet(
      int matchId, int setNumber, int loserId,
      {String? reason}) async {
    final response = await _dio.post(
      '/api/v1/matches/$matchId/sets/$setNumber/technical-defeat',
      data: {
        'loserId': loserId,
        if (reason != null) 'reason': reason,
      },
    );
    return MatchSetDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MatchDto> issueCard(int matchId, int playerId, String cardType) async {
    final response = await _dio.post(
      '/api/v1/matches/$matchId/cards',
      data: {'playerId': playerId, 'cardType': cardType},
    );
    return MatchDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MatchDto> revokeCard(int matchId, int cardId) async {
    final response =
        await _dio.delete('/api/v1/matches/$matchId/cards/$cardId');
    return MatchDto.fromJson(response.data as Map<String, dynamic>);
  }

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
