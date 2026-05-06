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
    required String substring,
    bool isSurname = false,
  }) {
    return _service.searchPlayersByName(query: substring, isSurname: isSurname);
  }

  Future<Player> fetchPlayerById(String id) {
    return _service.fetchPlayerById(id);
  }

  Future<void> updatePlayerProfileById(
          int playerId, Map<String, dynamic> fields) =>
      _service.updatePlayerProfileById(playerId, fields);

  Future<String> uploadPlayerAvatar(int playerId, Uint8List bytes) =>
      _service.uploadPlayerAvatar(playerId, bytes);
}
