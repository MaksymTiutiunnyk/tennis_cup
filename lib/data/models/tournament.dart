import 'package:intl/intl.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/models/player.dart';

DateFormat formatter = DateFormat('yyyy-MM-dd');

// ignore: constant_identifier_names
enum Time { Morning, Evening, Day, Midnight, Night }

class Tournament {
  final String tournamentId;
  final List<Player> players;
  List<Match>? matches;
  final DateTime date;
  final Arena arena;
  final Time time;
  final List<int> points;
  final List<int> places;
  bool isFinished;

  Tournament({
    required this.tournamentId,
    required this.players,
    required this.date,
    required this.arena,
    required this.time,
    required this.points,
    required this.places,
    this.isFinished = false,
    this.matches,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Tournament) return false;
    return tournamentId == other.tournamentId;
  }

  @override
  int get hashCode => tournamentId.hashCode;
}
