import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/data/models/gender.dart';
import 'package:tennis_cup/data/models/user.dart';
import 'package:tennis_cup/data/models/user_role.dart';
import 'package:tennis_cup/data/services/abstract/i_player_service.dart';

class RestPlayerService implements IPlayerService {
  final Dio _dio;

  const RestPlayerService(this._dio);

  @override
  Future<PageResult<User>> fetchRankingPlayers({
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

    final ratingRecords = content
        .map((json) => _userFromRatingRecord(json as Map<String, dynamic>))
        .toList();

    final enriched = await Future.wait(
      ratingRecords.map((r) async {
        try {
          final full = await fetchPlayerById(r.id);
          return User(
            id: full.id,
            firstName: full.firstName,
            lastName: full.lastName,
            patronymicName: full.patronymicName,
            gender: full.gender,
            birthDate: full.birthDate,
            city: full.city,
            country: full.country,
            imageUrl: full.imageUrl,
            roles: full.roles,
            status: full.status,
            tournaments: full.tournaments,
            matches: full.matches,
            wins: full.wins,
            losses: full.losses,
            goldPlaces: full.goldPlaces,
            silverPlaces: full.silverPlaces,
            bronzePlaces: full.bronzePlaces,
            rating: r.rating,
          );
        } catch (_) {
          return r;
        }
      }),
    );

    return PageResult(
      items: enriched,
      hasMore: page.page + 1 < totalPages,
    );
  }

  @override
  Future<User> fetchPlayerById(int id) async {
    final response = await _dio.get('/api/v1/users/$id');
    return _userFromProfileJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<User>> searchPlayersByName({
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
        .map((e) => _userFromSearchResult(e as Map<String, dynamic>))
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

  static User _userFromRatingRecord(Map<String, dynamic> json) {
    return User(
      id: (json['userId'] as num).toInt(),
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      rating: (json['ratingValue'] as num?)?.toDouble() ?? 0,
    );
  }

  static User _userFromProfileJson(Map<String, dynamic> json) {
    final stats = json['statistics'] as Map<String, dynamic>?;
    final roleStrings = json['roles'] as List<dynamic>? ?? const [];
    final roles = roleStrings
        .map((r) => userRoleFromString(r as String))
        .whereType<UserRole>()
        .toList();
    return User(
      id: (json['id'] as num).toInt(),
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      gender: genderFromString(json['gender'] as String?),
      birthDate: json['birthDate'] as String?,
      city: json['city'] as String? ?? '',
      country: json['country'] as String? ?? '',
      patronymicName: json['patronymicName'] as String? ?? '',
      roles: roles,
      tournaments: (stats?['totalFinishedTournaments'] as num?)?.toInt() ?? 0,
      matches: (stats?['totalMatches'] as num?)?.toInt() ?? 0,
      wins: (stats?['wins'] as num?)?.toInt() ?? 0,
      losses: (stats?['losses'] as num?)?.toInt() ?? 0,
      goldPlaces: (stats?['firstPlaceCount'] as num?)?.toInt() ?? 0,
      silverPlaces: (stats?['secondPlaceCount'] as num?)?.toInt() ?? 0,
      bronzePlaces: (stats?['thirdPlaceCount'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      imageUrl: json['avatarUrl'] as String? ?? '',
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }

  static User _userFromSearchResult(Map<String, dynamic> json) {
    final roleStrings = json['roles'] as List<dynamic>? ?? const [];
    final roles = roleStrings
        .map((r) => userRoleFromString(r as String))
        .whereType<UserRole>()
        .toList();
    return User(
      id: (json['userId'] as num).toInt(),
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      roles: roles,
      city: json['city'] as String? ?? '',
      country: json['country'] as String? ?? '',
      imageUrl: json['avatarUrl'] as String? ?? '',
    );
  }
}
