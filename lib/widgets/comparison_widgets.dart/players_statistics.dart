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
            label: 'Tennis Cup Rank',
            player1: (30.3).toString(),
            player2: (34.7).toString(),
          ),
          PlayersStatistic(
            label: 'UTTF Rank',
            player1: (30.3).toString(),
            player2: (34.7).toString(),
          ),
          const PlayersStatistic(
            label: 'City, Country',
            player1: 'Kyiv, Ukraine',
            player2: 'Kyiv, Ukraine',
          ),
          PlayersStatistic(
            label: 'Year of birth',
            player1: 1995.toString(),
            player2: 1995.toString(),
          ),
          PlayersStatistic(
            label: 'Tournaments',
            player1: 106.toString(),
            player2: 253.toString(),
          ),
          PlayersStatistic(
            label: 'Matches',
            player1: 531.toString(),
            player2: 1263.toString(),
          ),
          PlayersStatistic(
            label: 'Wins',
            player1: 300.toString(),
            player2: 642.toString(),
          ),
          PlayersStatistic(
            label: 'Loses',
            player1: 231.toString(),
            player2: 621.toString(),
          ),
        ],
      ),
    );
  }
}
