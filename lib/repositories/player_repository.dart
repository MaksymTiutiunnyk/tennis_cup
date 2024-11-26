import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennis_cup/model/player.dart';

class PlayerRepository {
  static Future<Map<String, dynamic>> fetchRankingPlayers({
    required int limit,
    DocumentSnapshot? startAfter,
    Sex? sexFilter,
  }) async {
    Query query =
        FirebaseFirestore.instance.collection('players').orderBy('rank_tennis', descending: true).limit(limit);

    if (sexFilter != null && sexFilter != Sex.All) {
      query = query.where('sex', isEqualTo: sexFilter.name);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final querySnapshot = await query.get();
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
