import 'dart:typed_data';

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
      if (sexFilter == Sex.Men) 'gender': 'MALE',
      if (sexFilter == Sex.Women) 'gender': 'FEMALE',
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
  Future<Player> fetchPlayerById(int id) async {
    final response = await _dio.get('/api/v1/users/$id');
    return _playerFromProfileJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<Player>> searchPlayersByName({
    required String query,
    String? gender,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/users/search',
      queryParameters: {
        'query': query,
        'size': 20,
        'roles': ['PLAYER'],
        if (gender != null) 'gender': gender,
      },
    );
    final content = (response.data!['content'] as List<dynamic>);
    return content
        .map((e) => _playerFromSearchResult(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> updateProfile(int id, Map<String, dynamic> fields) async {
    await _dio.patch<void>('/api/v1/admin/users/$id', data: fields);
  }

  @override
  Future<String> uploadAvatar(int id, Uint8List bytes) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: 'avatar.jpg',
        contentType: DioMediaType('image', 'jpeg'),
      ),
    });
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/v1/users/$id/avatar',
      data: formData,
    );
    return response.data!['avatarUrl'] as String;
  }

  static Player _playerFromRatingRecord(Map<String, dynamic> json) {
    return Player(
      userId: (json['userId'] as num).toInt(),
      name: json['firstName'] as String? ?? '',
      surname: json['lastName'] as String? ?? '',
      sex: Sex.All,
      tournaments: 0,
      matches: 0,
      wins: 0,
      loses: 0,
      gold: 0,
      silver: 0,
      bronze: 0,
      rankTennis: (json['ratingValue'] as num?)?.toDouble() ?? 0,
      rankUTTF: 0,
      imageUrl: '',
    );
  }

  static Player _playerFromProfileJson(Map<String, dynamic> json) {
    final gender = json['gender'] as String? ?? '';
    final stats = json['statistics'] as Map<String, dynamic>?;
    return Player(
      userId: (json['id'] as num).toInt(),
      name: json['firstName'] as String? ?? '',
      surname: json['lastName'] as String? ?? '',
      sex: gender == 'MALE'
          ? Sex.Men
          : (gender == 'FEMALE' ? Sex.Women : Sex.All),
      birthDate: json['birthDate'] as String?,
      city: json['city'] as String? ?? '',
      country: json['country'] as String? ?? '',
      patronymicName: json['patronymicName'] as String? ?? '',
      tournaments: (stats?['totalFinishedTournaments'] as num?)?.toInt() ?? 0,
      matches: (stats?['totalMatches'] as num?)?.toInt() ?? 0,
      wins: (stats?['wins'] as num?)?.toInt() ?? 0,
      loses: (stats?['losses'] as num?)?.toInt() ?? 0,
      gold: (stats?['firstPlaceCount'] as num?)?.toInt() ?? 0,
      silver: (stats?['secondPlaceCount'] as num?)?.toInt() ?? 0,
      bronze: (stats?['thirdPlaceCount'] as num?)?.toInt() ?? 0,
      rankTennis: 0,
      rankUTTF: 0,
      imageUrl: json['avatarUrl'] as String? ?? '',
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }

  static Player _playerFromSearchResult(Map<String, dynamic> json) {
    return Player(
      userId: (json['userId'] as num).toInt(),
      name: json['firstName'] as String? ?? '',
      surname: json['lastName'] as String? ?? '',
      sex: Sex.All,
      city: json['city'] as String? ?? '',
      country: json['country'] as String? ?? '',
      tournaments: 0,
      matches: 0,
      wins: 0,
      loses: 0,
      gold: 0,
      silver: 0,
      bronze: 0,
      rankTennis: 0,
      rankUTTF: 0,
      imageUrl: json['avatarUrl'] as String? ?? '',
    );
  }
}
