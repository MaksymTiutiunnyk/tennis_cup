import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennis_cup/data/models/player.dart';

class Match {
  final String matchId;
  final Player bluePlayer;
  final Player redPlayer;
  final int blueScore;
  final int redScore;
  final List<int> blueSetScores;
  final List<int> redSetScores;
  final String tournamentId;
  final DateTime dateTime;

  Match(
      {required this.matchId,
      required this.bluePlayer,
      required this.redPlayer,
      required this.tournamentId,
      required this.dateTime,
      required this.blueSetScores,
      required this.redSetScores,
      required this.blueScore,
      required this.redScore});

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
      matchId: matchDoc.id,
      bluePlayer: Player.fromFirestore(bluePlayerDoc),
      redPlayer: Player.fromFirestore(redPlayerDoc),
      dateTime: dateTime,
      tournamentId: data['tournamentId'],
      blueSetScores: (data['blueSetScores'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      redSetScores:
          (data['redSetScores'] as List<dynamic>).map((e) => e as int).toList(),
      blueScore: data['blueScore'],
      redScore: data['redScore'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Match) return false;
    return matchId == other.matchId &&
        bluePlayer == other.bluePlayer &&
        redPlayer == other.redPlayer &&
        blueScore == other.blueScore &&
        redScore == other.redScore;
  }

  @override
  int get hashCode => Object.hash(matchId, bluePlayer, redPlayer, blueScore, redScore);
}
