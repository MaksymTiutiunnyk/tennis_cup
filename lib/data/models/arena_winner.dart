import 'package:equatable/equatable.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/models/user.dart';

class ArenaWinner extends Equatable {
  final String arenaName;
  final ArenaColor arenaColor;
  final int tournamentId;
  final String tournamentName;
  final String tournamentGender;
  final Time tournamentTime;
  final DateTime tournamentStart;
  final List<User> winners;

  const ArenaWinner({
    required this.arenaName,
    required this.arenaColor,
    required this.tournamentId,
    required this.tournamentName,
    required this.tournamentGender,
    required this.tournamentTime,
    required this.tournamentStart,
    required this.winners,
  });

  @override
  List<Object?> get props => [
        arenaName,
        arenaColor,
        tournamentId,
        tournamentName,
        tournamentGender,
        tournamentTime,
        tournamentStart,
        winners,
      ];
}
