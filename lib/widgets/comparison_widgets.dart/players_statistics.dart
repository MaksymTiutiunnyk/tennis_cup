import 'package:flutter/material.dart';
import 'package:tennis_cup/model/player.dart';
import 'package:tennis_cup/widgets/comparison_widgets.dart/players_statistic.dart';

class PlayersStatistics extends StatelessWidget {
  final Player player1, player2;
  const PlayersStatistics(
      {required this.player1, required this.player2, super.key});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.loose,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PlayersStatistic(
            label: 'Tennis Cup Rank:',
            player1: player1.rankTennis.toString(),
            player2: player2.rankTennis.toString(),
          ),
          PlayersStatistic(
            label: 'UTTF Rank:',
            player1: player1.rankUTTF.toString(),
            player2: player2.rankUTTF.toString(),
          ),
          PlayersStatistic(
            label: 'City, Country:',
            player1: player1.place,
            player2: player2.place,
          ),
          PlayersStatistic(
            label: 'Year of birth:',
            player1: player1.year.toString(),
            player2: player2.year.toString(),
          ),
          PlayersStatistic(
            label: 'Tournaments:',
            player1: player1.tournaments.toString(),
            player2: player2.tournaments.toString(),
          ),
          PlayersStatistic(
            label: 'Matches:',
            player1: player1.matches.toString(),
            player2: player2.matches.toString(),
          ),
          PlayersStatistic(
            label: 'Wins:',
            player1: player1.wins.toString(),
            player2: player2.wins.toString(),
          ),
          PlayersStatistic(
            label: 'Loses:',
            player1: player1.loses.toString(),
            player2: player2.loses.toString(),
          ),
        ],
      ),
    );
  }
}
