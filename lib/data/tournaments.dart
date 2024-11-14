import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/data/arenas.dart';

final List<Tournament> tournaments = [
  Tournament(players: players.take(6).toList(), date: DateTime(2024, 10, 30), arena: arenas[1], time: Time.Evening),
  Tournament(players: players.take(6).toList(), date: DateTime(2024, 11, 05), arena: arenas[2], time: Time.Morning)

];
