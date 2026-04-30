import 'package:tennis_cup/data/models/page_request.dart';
import 'package:tennis_cup/data/models/page_result.dart';
import 'package:tennis_cup/data/models/player.dart';

abstract interface class IPlayerService {
  Future<PageResult<Player>> fetchRankingPlayers({
    required PageRequest page,
    Sex? sexFilter,
  });

  Future<List<Player>> searchPlayersByName({
    required String query,
    bool isSurname = false,
  });

  Future<Player> fetchPlayerById(String id);
}
