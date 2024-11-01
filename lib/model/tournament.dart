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

  Tournament(
      {required this.players,
      required this.date,
      required this.arena,
      required this.time})
      : title = '${formatter.format(date)} Men ${time.name} ${arena.title}';
}
