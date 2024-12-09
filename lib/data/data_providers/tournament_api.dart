import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/tournament.dart';

class TournamentApi {
  const TournamentApi();

  Future<QuerySnapshot> fetchPlayerTournaments({
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

    return await query.get();
  }

  Future<QuerySnapshot> fetchScheduledTournament(
      {required DateTime tournamentDate,
      required Arena tournamentArena,
      required Time tournamentTime}) async {
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

    return await FirebaseFirestore.instance
        .collection('tournaments')
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .where('time', isEqualTo: tournamentTime.name)
        .where('arena', isEqualTo: tournamentArena.title)
        .get();
  }

  Future<QuerySnapshot> fetchLiveStreamMatchesTournaments() async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('tournaments')
        .orderBy('date', descending: true)
        .limit(10)
        .get();

    return querySnapshot;
  }

  Future<QuerySnapshot> fetchUpcomingMatchesTournaments() async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('tournaments')
        .where('isFinished', isNotEqualTo: true)
        .orderBy('date', descending: true)
        .limit(10)
        .get();

    return querySnapshot;
  }

  Future<QuerySnapshot> fetchWinnersTournaments() async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('tournaments')
        .where('isFinished', isEqualTo: true)
        .orderBy('date', descending: true)
        .limit(10)
        .get();

    return querySnapshot;
  }

  Stream<void> watchTournamentChanges(String tournamentId) {
    return FirebaseFirestore.instance
        .collectionGroup('matches')
        .where('tournamentId', isEqualTo: tournamentId)
        .snapshots();
  }

  Future<DocumentSnapshot> fetchTournamentById({
    required String tournamentId,
  }) async {
    DocumentSnapshot tournamentSnapshot = await FirebaseFirestore.instance
        .collection('tournaments')
        .doc(tournamentId)
        .get();

    return tournamentSnapshot;
  }
}
