import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/page_request.dart';
import 'package:tennis_cup/data/models/page_result.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/repositories/arena_repository.dart';
import 'package:tennis_cup/data/services/abstract/i_tournament_service.dart';

final _dateFormat = DateFormat('yyyy-MM-dd');

class RestTournamentService implements ITournamentService {
  final Dio _dio;
  // TODO: remove dependency
  final ArenaRepository _arenaRepository;

  const RestTournamentService(this._dio, this._arenaRepository);

  @override
  Future<PageResult<Tournament>> fetchPlayerTournaments({
    required String playerId,
    String? player2Id,
    required PageRequest page,
  }) async {
    final response = await _dio.get('/api/v1/tournaments', queryParameters: {
      'page': page.page,
      'size': page.size,
      'sortDirection': 'DESC',
    });

    final body = response.data as Map<String, dynamic>;
    final content = body['content'] as List<dynamic>;
    final totalPages = body['totalPages'] as int? ?? 1;

    final arenas = await _arenaRepository.fetchAllArenas();
    final tournaments = <Tournament>[];

    for (final json in content) {
      final t = _parseTournament(json as Map<String, dynamic>, arenas);
      final ids = (json['playerIds'] as List<dynamic>?)
              ?.map((id) => id.toString())
              .toList() ??
          [];
      if (!ids.contains(playerId)) continue;
      if (player2Id != null && !ids.contains(player2Id)) continue;
      tournaments.add(t);
    }

    return PageResult(
      items: tournaments,
      hasMore: page.page + 1 < totalPages,
    );
  }

  @override
  Future<Tournament> fetchTournamentById(String id) async {
    final response = await _dio.get('/api/v1/tournaments/$id');
    final arenas = await _arenaRepository.fetchAllArenas();
    return _parseTournament(response.data as Map<String, dynamic>, arenas);
  }

  @override
  Future<List<Tournament>> fetchScheduledTournaments({
    required DateTime date,
    required Arena arena,
    required Time time,
  }) async {
    final queryParams = <String, dynamic>{
      'start': _dateFormat.format(date),
      'sortDirection': 'ASC',
    };
    if (arena.id != null) queryParams['arenaId'] = arena.id;

    final response =
        await _dio.get('/api/v1/tournaments', queryParameters: queryParams);
    final body = response.data as Map<String, dynamic>;
    final content = body['content'] as List<dynamic>;
    final arenas = await _arenaRepository.fetchAllArenas();

    return content
        .map((json) => _parseTournament(json as Map<String, dynamic>, arenas))
        .where((t) => t.time == time)
        .toList();
  }

  @override
  Future<List<Tournament>> fetchRecentTournaments({int limit = 10}) async {
    final response = await _dio.get('/api/v1/tournaments', queryParameters: {
      'status': 'FINISHED',
      'size': limit,
      'sortDirection': 'DESC',
    });
    final body = response.data as Map<String, dynamic>;
    final content = body['content'] as List<dynamic>;
    final arenas = await _arenaRepository.fetchAllArenas();

    return content
        .map((json) => _parseTournament(json as Map<String, dynamic>, arenas))
        .toList();
  }

  @override
  Future<List<Tournament>> fetchUpcomingTournaments({int limit = 10}) async {
    final response = await _dio.get('/api/v1/tournaments', queryParameters: {
      'status': 'PENDING',
      'size': limit,
      'sortDirection': 'ASC',
    });
    final body = response.data as Map<String, dynamic>;
    final content = body['content'] as List<dynamic>;
    final arenas = await _arenaRepository.fetchAllArenas();

    return content
        .map((json) => _parseTournament(json as Map<String, dynamic>, arenas))
        .toList();
  }

  @override
  Stream<void> watchTournamentChanges(String tournamentId) =>
      const Stream.empty();

  Tournament _parseTournament(
    Map<String, dynamic> json,
    List<Arena> arenas,
  ) {
    final arenaId = json['arenaId']?.toString();
    final arena = arenas.firstWhere(
      (a) => a.id == arenaId,
      orElse: () =>
          Arena(title: arenaId ?? 'Unknown', color: const Color(0xFF9E9E9E)),
    );
    return Tournament(
      tournamentId: json['id']?.toString() ?? '',
      date: DateTime.parse(json['startTime'] as String),
      players: const [],
      arena: arena,
      time: _timeFromString(json['type'] as String? ?? ''),
      points: const [],
      places: const [],
      isFinished: (json['status'] as String? ?? '') == 'FINISHED',
      matches: null,
    );
  }

  static Time _timeFromString(String value) {
    switch (value.toUpperCase()) {
      case 'MORNING':
        return Time.Morning;
      case 'DAY':
        return Time.Day;
      case 'EVENING':
        return Time.Evening;
      case 'NIGHT':
        return Time.Night;
      default:
        return Time.Morning;
    }
  }
}
