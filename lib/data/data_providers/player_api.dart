import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennis_cup/data/models/player.dart';

class PlayerApi {
  const PlayerApi();

  Future<QuerySnapshot> fetchRankingPlayers({
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

    return await query.get();
  }
}