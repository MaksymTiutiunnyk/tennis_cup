import 'package:tennis_cup/model/player.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:intl/intl.dart';

DateFormat formatter = DateFormat('hh:mm');

class Match {
  final Player bluePlayer;
  final Player redPlayer;
  int blueScore;
  int redScore;
  final Tournament tournament;
  DateTime dateTime;

  Match(
      {required this.bluePlayer,
      required this.redPlayer,
      this.blueScore = 0,
      this.redScore = 0,
      required this.tournament,
      required this.dateTime});

  String getFormattedTime() {
    return formatter.format(dateTime);
  }
}
