import 'dart:typed_data';

import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/services/abstract/i_player_service.dart';

class PlayerRepository {
  final IPlayerService _service;

  const PlayerRepository(this._service);

  Future<PageResult<Player>> fetchRankingPlayers({
    required PageRequest page,
    Sex? sexFilter,
  }) {
    return _service.fetchRankingPlayers(page: page, sexFilter: sexFilter);
  }

  Future<List<Player>> fetchPlayersBySubstring({
    required String query,
    String? gender,
  }) {
    return _service.searchPlayersByName(query: query, gender: gender);
  }

  Future<Player> fetchPlayerById(int id) {
    return _service.fetchPlayerById(id);
  }

  Future<void> updateProfile(int id, Map<String, dynamic> fields) =>
      _service.updateProfile(id, fields);

  Future<String> uploadAvatar(int id, Uint8List bytes) =>
      _service.uploadAvatar(id, bytes);
}
