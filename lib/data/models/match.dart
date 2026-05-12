import 'package:equatable/equatable.dart';
import 'package:tennis_cup/data/models/player.dart';

class Match extends Equatable {
  final String matchId;
  final Player bluePlayer;
  final Player redPlayer;
  final int blueScore;
  final int redScore;
  final List<int> blueSetScores;
  final List<int> redSetScores;
  final String tournamentId;
  final DateTime dateTime;
  final bool isTechnicalDefeat;
  final int? winnerId;

  const Match({
    required this.matchId,
    required this.bluePlayer,
    required this.redPlayer,
    required this.tournamentId,
    required this.dateTime,
    required this.blueSetScores,
    required this.redSetScores,
    required this.blueScore,
    required this.redScore,
    this.isTechnicalDefeat = false,
    this.winnerId,
  });

  @override
  List<Object?> get props => [
        matchId,
        bluePlayer,
        redPlayer,
        blueScore,
        redScore,
        blueSetScores,
        redSetScores,
        tournamentId,
        dateTime,
        isTechnicalDefeat,
        winnerId,
      ];
}
