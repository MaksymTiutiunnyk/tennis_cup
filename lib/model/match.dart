import 'package:tennis_cup/model/arena.dart';
import 'package:tennis_cup/model/player.dart';

class Match {
  final Player bluePlayer;
  final Player redPlayer;
  int blueScore;
  int redScore;
  final Arena arena;
  DateTime? dateTime;

  Match({required this.bluePlayer, required this.redPlayer, this.blueScore = 0, this.redScore = 0, required this.arena, this.dateTime});
}