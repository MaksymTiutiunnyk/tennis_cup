import 'dart:typed_data';

import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/data/models/player.dart';

abstract interface class IPlayerService {
  Future<PageResult<Player>> fetchRankingPlayers({
    required PageRequest page,
    Sex? sexFilter,
  });

  Future<List<Player>> searchPlayersByName({
    required String query,
    String? gender,
  });

  Future<Player> fetchPlayerById(int id);

  Future<void> updateProfile(int id, Map<String, dynamic> fields);

  Future<String> uploadAvatar(int id, Uint8List bytes);
}
