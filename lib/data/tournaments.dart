import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/data/players.dart';
import 'package:tennis_cup/data/arenas.dart';

final List<Tournament> tournaments = [
  Tournament(players: players.take(6).toList(), date: DateTime(2024, 10, 30), arena: arenas[1], time: Time.evening)
];