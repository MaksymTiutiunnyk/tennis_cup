import 'dart:typed_data';

import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/data/models/gender.dart';
import 'package:tennis_cup/data/models/user.dart';
import 'package:tennis_cup/data/models/user_role.dart';
import 'package:tennis_cup/data/services/abstract/i_player_service.dart';
import 'package:tennis_cup/data/services/dto/rating_record_dto.dart';
import 'package:tennis_cup/data/services/dto/user_search_result_dto.dart';

class PlayerRepository {
  final IPlayerService _service;

  const PlayerRepository(this._service);

  Future<PageResult<User>> fetchRankingPlayers({
    required PageRequest page,
    Gender? genderFilter,
  }) async {
    final result = await _service.fetchRankingPlayers(
        page: page, genderFilter: genderFilter);
    return PageResult(
      items: result.items.map(_toUser).toList(),
      hasMore: result.hasMore,
    );
  }

  static User _toUser(RatingRecordDto dto) => User(
        id: dto.userId,
        firstName: dto.firstName,
        lastName: dto.lastName,
        gender: genderFromString(dto.gender),
        birthDate: dto.birthDate,
        city: dto.city ?? '',
        country: dto.country ?? '',
        rating: dto.ratingValue,
      );

  Future<List<User>> fetchPlayersBySubstring({
    required String query,
    String? gender,
  }) async {
    final dtos =
        await _service.searchPlayersByName(query: query, gender: gender);
    return dtos.map(_toUserFromSearch).toList();
  }

  static User _toUserFromSearch(UserSearchResultDto dto) => User(
        id: dto.userId,
        firstName: dto.firstName,
        lastName: dto.lastName,
        roles: dto.roles.map(userRoleFromString).whereType<UserRole>().toList(),
        city: dto.city ?? '',
        country: dto.country ?? '',
        imageUrl: dto.avatarUrl ?? '',
      );

  Future<User> fetchPlayerById(int id) {
    return _service.fetchPlayerById(id);
  }

  Future<void> updateProfile(int id, Map<String, dynamic> fields) =>
      _service.updateProfile(id, fields);

  Future<String> uploadAvatar(int id, Uint8List bytes) =>
      _service.uploadAvatar(id, bytes);

  Future<void> removeAvatar(int id) => _service.removeAvatar(id);
}
