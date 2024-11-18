import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennis_cup/model/tournament.dart';

class TournamentRepository {
  static Future<Map<String, dynamic>> fetchPlayerTournaments({
    required String playerId,
    required int limit,
    DocumentSnapshot? startAfter,
  }) async {
    Query query = FirebaseFirestore.instance
        .collection('tournaments')
        .where('players', arrayContains: playerId)
        .orderBy('date', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final querySnapshot = await query.get();
    final tournaments = querySnapshot.docs.map((doc) {
      return Tournament.fromFirestore(doc);
    }).toList();

    return {
      'tournaments': tournaments,
      'lastDocument':
          querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null,
    };
  }
}