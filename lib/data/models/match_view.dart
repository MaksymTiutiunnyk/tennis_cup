import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/models/tournament.dart';

class MatchView extends Equatable {
  final String matchId;
  final String arenaId;
  final String arenaName;
  final Color arenaColor;
  final String tournamentId;
  final String tournamentGender;
  final Time tournamentTime;
  final DateTime tournamentStart;
  final Player bluePlayer;
  final Player redPlayer;
  final int blueScore;
  final int redScore;

  const MatchView({
    required this.matchId,
    required this.arenaId,
    required this.arenaName,
    required this.arenaColor,
    required this.tournamentId,
    required this.tournamentGender,
    required this.tournamentTime,
    required this.tournamentStart,
    required this.bluePlayer,
    required this.redPlayer,
    required this.blueScore,
    required this.redScore,
  });

  @override
  List<Object?> get props => [
        matchId,
        arenaId,
        arenaName,
        arenaColor,
        tournamentId,
        tournamentGender,
        tournamentTime,
        tournamentStart,
        bluePlayer,
        redPlayer,
        blueScore,
        redScore,
      ];
}
