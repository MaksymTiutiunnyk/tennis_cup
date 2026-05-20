import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/data/models/gender.dart';
import 'package:tennis_cup/data/services/abstract/i_player_service.dart';
import 'package:tennis_cup/data/services/dto/rating_record_dto.dart';
import 'package:tennis_cup/data/services/dto/player_profile_dto.dart';
import 'package:tennis_cup/data/services/dto/player_search_result_dto.dart';
import 'package:tennis_cup/data/services/dto/user_brief_dto.dart';

class RestPlayerService implements IPlayerService {
  final Dio _dio;

  const RestPlayerService(this._dio);

  @override
  Future<PageResult<RatingRecordDto>> fetchRankingPlayers({
    required PageRequest page,
    Gender? genderFilter,
  }) async {
    final response = await _dio.get('/api/v1/ratings', queryParameters: {
      'page': page.page,
      'size': page.size,
      'sortBy': 'ratingValue',
      'sortDirection': 'DESC',
      if (genderFilter == Gender.male) 'gender': 'MALE',
      if (genderFilter == Gender.female) 'gender': 'FEMALE',
    });

    final body = response.data as Map<String, dynamic>;
    final content = body['content'] as List<dynamic>;
    final totalPages = body['totalPages'] as int? ?? 1;

    final items = content
        .map((json) => RatingRecordDto.fromJson(json as Map<String, dynamic>))
        .toList();

    return PageResult(
      items: items,
      hasMore: page.page + 1 < totalPages,
    );
  }

  @override
  Future<PlayerProfileDto> fetchPlayerById(int id) async {
    final response = await _dio.get('/api/v1/users/$id');
    return PlayerProfileDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<UserBriefDto>> fetchUsersBatch(List<int> userIds) async {
    if (userIds.isEmpty) return const [];
    final response = await _dio.post<List<dynamic>>(
      '/api/v1/users/batch',
      data: {'userIds': userIds},
    );
    return response.data!
        .map((e) => UserBriefDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<PlayerSearchResultDto>> searchPlayersByName({
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
        .map((e) => PlayerSearchResultDto.fromJson(e as Map<String, dynamic>))
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

  @override
  Future<void> removeAvatar(int id) async {
    final formData = FormData.fromMap({});
    await _dio.put<void>('/api/v1/users/$id/avatar', data: formData);
  }
}
