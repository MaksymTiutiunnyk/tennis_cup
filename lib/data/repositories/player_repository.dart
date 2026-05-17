import 'dart:typed_data';

import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/data/models/gender.dart';
import 'package:tennis_cup/data/models/user.dart';
import 'package:tennis_cup/data/services/abstract/i_player_service.dart';

class PlayerRepository {
  final IPlayerService _service;

  const PlayerRepository(this._service);

  Future<PageResult<User>> fetchRankingPlayers({
    required PageRequest page,
    Gender? genderFilter,
  }) {
    return _service.fetchRankingPlayers(page: page, genderFilter: genderFilter);
  }

  Future<List<User>> fetchPlayersBySubstring({
    required String query,
    String? gender,
  }) {
    return _service.searchPlayersByName(query: query, gender: gender);
  }

  Future<User> fetchPlayerById(int id) {
    return _service.fetchPlayerById(id);
  }

  Future<void> updateProfile(int id, Map<String, dynamic> fields) =>
      _service.updateProfile(id, fields);

  Future<String> uploadAvatar(int id, Uint8List bytes) =>
      _service.uploadAvatar(id, bytes);

  Future<void> removeAvatar(int id) => _service.removeAvatar(id);
}
