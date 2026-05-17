import 'package:flutter/material.dart';
import 'package:tennis_cup/data/models/user.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/ui/view_only/player_comparison/widgets/players_statistic.dart';

class PlayersStatistics extends StatelessWidget {
  final User player1, player2;
  const PlayersStatistics(
      {required this.player1, required this.player2, super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Flexible(
      fit: FlexFit.loose,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PlayersStatistic(
            label: s.labelTennisCupRank,
            player1: player1.rating.toString(),
            player2: player2.rating.toString(),
          ),
          PlayersStatistic(
            label: s.labelCityCountry,
            player1: player1.place,
            player2: player2.place,
          ),
          PlayersStatistic(
            label: s.labelYearOfBirth,
            player1: player1.year.toString(),
            player2: player2.year.toString(),
          ),
          PlayersStatistic(
            label: s.tournaments,
            player1: player1.tournaments.toString(),
            player2: player2.tournaments.toString(),
          ),
          PlayersStatistic(
            label: s.labelMatches,
            player1: player1.matches.toString(),
            player2: player2.matches.toString(),
          ),
          PlayersStatistic(
            label: s.labelWins,
            player1: player1.wins.toString(),
            player2: player2.wins.toString(),
          ),
          PlayersStatistic(
            label: s.labelLosses,
            player1: player1.losses.toString(),
            player2: player2.losses.toString(),
          ),
        ],
      ),
    );
  }
}
