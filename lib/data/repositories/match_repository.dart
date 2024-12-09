import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennis_cup/data/data_providers/match_api.dart';
import 'package:tennis_cup/data/models/match.dart';

class MatchRepository {
  final MatchApi matchApi;

  const MatchRepository({required this.matchApi});

  Future<Match> fetchMatchById({
    required String matchId,
  }) async {
    DocumentSnapshot? matchSnapshot = await matchApi.fetchMatchById(matchId);

    return await Match.fromFirestore(matchSnapshot!);
  }

  Stream<void> watchMatchChanges(String matchId) {
    return matchApi.watchMatchChanges(matchId);
  }
}
