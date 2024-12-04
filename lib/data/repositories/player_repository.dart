import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennis_cup/data/data_providers/player_api.dart';
import 'package:tennis_cup/data/models/player.dart';

class PlayerRepository {
  final PlayerApi playerApi;

  const PlayerRepository({required this.playerApi});

  Future<Map<String, dynamic>> fetchRankingPlayers({
    required int limit,
    DocumentSnapshot? startAfter,
    Sex? sexFilter,
  }) async {
    final querySnapshot = await playerApi.fetchRankingPlayers(
      limit: limit,
      startAfter: startAfter,
      sexFilter: sexFilter,
    );

    final players = querySnapshot.docs.map((doc) {
      return Player.fromFirestore(doc);
    }).toList();

    return {
      'players': players,
      'lastDocument':
          querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null,
    };
  }
}
