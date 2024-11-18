import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennis_cup/model/arena.dart';
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

  static Future<List<Tournament>> fetchScheduledTournament(
      {required DateTime tournamentDate,
      required Arena tournamentArena,
      required Time tournamentTime}) async {
    final tournamentsCollection =
        FirebaseFirestore.instance.collection('tournaments');

    final Timestamp startOfDay = Timestamp.fromDate(DateTime(
      tournamentDate.year,
      tournamentDate.month,
      tournamentDate.day,
      0,
      0,
      0,
    ));
    final Timestamp endOfDay = Timestamp.fromDate(DateTime(
      tournamentDate.year,
      tournamentDate.month,
      tournamentDate.day,
      23,
      59,
      59,
    ));

    final querySnapshot = await tournamentsCollection
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .where('time', isEqualTo: tournamentTime.name)
        .where('arena', isEqualTo: tournamentArena.title)
        .get();

    List<Tournament> filteredTournaments = await Future.wait(
        querySnapshot.docs.map((doc) async => Tournament.fromFirestore(doc)));

    return filteredTournaments;
  }
}
