import 'package:tennis_cup/model/player.dart';

class Tournament {
  List<Player> players;
  List<Match> matches;

  Tournament({required this.players, required this.matches});
}