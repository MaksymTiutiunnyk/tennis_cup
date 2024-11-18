import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennis_cup/data/arenas.dart';
import 'package:tennis_cup/model/arena.dart';
import 'package:tennis_cup/model/player.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/model/match.dart';

DateFormat formatter = DateFormat('yyyy-MM-dd');

// ignore: constant_identifier_names
enum Time { Morning, Evening, Day, Midnight, Night }

class Tournament {
  final List<Player> players;
  List<Match>? matches;
  final DateTime date;
  final Arena arena;
  final Time time;
  final String title;
  final List<int> points;
  final List<int> places;

  Tournament(
      {required this.players,
      required this.date,
      required this.arena,
      required this.time,
      required this.points,
      required this.places})
      : title =
            '${formatter.format(date)} ${players[0].sex.name} ${time.name} ${arena.title}';

  static Future<Tournament> fromFirestore(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;

    List<Player> players = [];
    if (data['players'] != null) {
      final playerIds = List<String>.from(data['players']);
      for (String playerId in playerIds) {
        final playerDoc = await FirebaseFirestore.instance
            .collection('players')
            .doc(playerId)
            .get();
        if (playerDoc.exists) {
          players.add(Player.fromFirestore(playerDoc));
        }
      }
    }

    final tournament = Tournament(
      date: (data['date'] as Timestamp).toDate(),
      players: players,
      arena: arenas.firstWhere((arena) => arena.title == data['arena']),
      places: List<int>.from(data['places']),
      points: List<int>.from(data['points']),
      time: Time.values.firstWhere((time) => time.name == data['time']),
    );

    final matchesSnapshot = await FirebaseFirestore.instance
        .collection('tournaments')
        .doc(doc.id)
        .collection('matches')
        .orderBy('dateTime')
        .get();

    tournament.matches = await Future.wait(matchesSnapshot.docs
        .map((matchDoc) => Match.fromFirestore(matchDoc))
        .toList());

    return tournament;
  }
}
