import 'package:equatable/equatable.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/models/tournament.dart';

class WinnerView extends Equatable {
  final String arenaName;
  final String tournamentId;
  final String tournamentName;
  final String tournamentGender;
  final Time tournamentTime;
  final DateTime tournamentStart;
  final List<Player> winners;

  const WinnerView({
    required this.arenaName,
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
        tournamentId,
        tournamentName,
        tournamentGender,
        tournamentTime,
        tournamentStart,
        winners,
      ];
}
