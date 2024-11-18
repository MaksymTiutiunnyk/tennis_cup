import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennis_cup/model/player.dart';

class Match {
  final Player bluePlayer;
  final Player redPlayer;
  int blueScore = 0;
  int redScore = 0;
  final List<int> blueSetScores = [];
  final List<int> redSetScores = [];
  final String tournamentId;
  final DateTime dateTime;

  Match(
      {required this.bluePlayer,
      required this.redPlayer,
      required this.tournamentId,
      required this.dateTime});

  static Future<Match> fromFirestore(DocumentSnapshot matchDoc) async {
    final data = matchDoc.data() as Map<String, dynamic>;

    final bluePlayerId = data['bluePlayerId'];
    final bluePlayerDoc = await FirebaseFirestore.instance
        .collection('players')
        .doc(bluePlayerId)
        .get();

    final redPlayerId = data['redPlayerId'];
    final redPlayerDoc = await FirebaseFirestore.instance
        .collection('players')
        .doc(redPlayerId)
        .get();

    final dateTime = (data['dateTime'] as Timestamp).toDate();

    return Match(
      bluePlayer: Player.fromFirestore(bluePlayerDoc),
      redPlayer: Player.fromFirestore(redPlayerDoc),
      dateTime: dateTime,
      tournamentId: data['tournamentId']
    );
  }
}