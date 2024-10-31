import 'package:tennis_cup/model/arena.dart';
import 'package:tennis_cup/model/player.dart';

enum Time { morning, evening, night, midnight}

class Tournament {
  final List<Player> players;
  List<Match>? matches;
  final DateTime date;
  final Arena arena;
  final Time time;

  Tournament({required this.players, required this.date, required this.arena, required this.time});
}