import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/models/player.dart';

DateFormat formatter = DateFormat('yyyy-MM-dd');

// ignore: constant_identifier_names
enum Time { Morning, Evening, Day, Midnight, Night }

class Tournament extends Equatable {
  final String tournamentId;
  final List<Player> players;
  final List<Match>? matches;
  final DateTime date;
  final Arena arena;
  final Time time;
  final List<int> points;
  final List<int> places;
  final bool isFinished;

  const Tournament({
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
  List<Object?> get props => [
        tournamentId,
        players,
        matches,
        date,
        arena,
        time,
        points,
        places,
        isFinished,
      ];
}
