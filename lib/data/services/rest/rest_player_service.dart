import 'package:dio/dio.dart';
import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/services/abstract/i_player_service.dart';

class RestPlayerService implements IPlayerService {
  final Dio _dio;

  const RestPlayerService(this._dio);

  @override
  Future<PageResult<Player>> fetchRankingPlayers({
    required PageRequest page,
    Sex? sexFilter,
  }) async {
    final response = await _dio.get('/api/v1/ratings', queryParameters: {
      'page': page.page,
      'size': page.size,
      'sortBy': 'ratingValue',
      'sortDirection': 'DESC',
    });

    final body = response.data as Map<String, dynamic>;
    final content = body['content'] as List<dynamic>;
    final totalPages = body['totalPages'] as int? ?? 1;

    final players = content
        .map((json) => _playerFromRatingRecord(json as Map<String, dynamic>))
        .toList();

    return PageResult(
      items: players,
      hasMore: page.page + 1 < totalPages,
    );
  }

  @override
  Future<Player> fetchPlayerById(String id) async {
    final response = await _dio.get('/api/v1/players/$id');
    return _playerFromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<Player>> searchPlayersByName({
    required String query,
    bool isSurname = false,
  }) async {
    // Player search endpoint not yet available in the backend.
    return [];
  }

  @override
  Future<void> updatePlayerProfileById(
      int playerId, Map<String, dynamic> fields) {
    // Admin endpoint PUT /api/v1/players/{id} not yet available in the backend.
    throw UnimplementedError('Admin player edit endpoint not yet available');
  }

  static Player _playerFromRatingRecord(Map<String, dynamic> json) {
    final gender = json['gender'] as String? ?? '';
    return Player(
      playerId: json['playerId']?.toString() ?? '',
      name: json['firstName'] as String? ?? '',
      surname: json['lastName'] as String? ?? '',
      sex: gender == 'MALE'
          ? Sex.Men
          : (gender == 'FEMALE' ? Sex.Women : Sex.All),
      year: 0,
      tournaments: 0,
      matches: 0,
      wins: 0,
      loses: 0,
      place: '',
      gold: 0,
      silver: 0,
      bronze: 0,
      rankTennis: (json['ratingValue'] as num?)?.toDouble() ?? 0,
      rankUTTF: 0,
      imageUrl: '',
    );
  }

  static Player _playerFromJson(Map<String, dynamic> json) {
    final gender = json['gender'] as String? ?? '';
    return Player(
      playerId: json['id']?.toString() ?? '',
      name: json['firstName'] as String? ?? '',
      surname: json['lastName'] as String? ?? '',
      sex: gender == 'MALE'
          ? Sex.Men
          : (gender == 'FEMALE' ? Sex.Women : Sex.All),
      year: 0,
      tournaments: 0,
      matches: 0,
      wins: 0,
      loses: 0,
      place: '',
      gold: 0,
      silver: 0,
      bronze: 0,
      rankTennis: 0,
      rankUTTF: 0,
      imageUrl: '',
    );
  }
}
