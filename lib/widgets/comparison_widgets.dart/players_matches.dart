import 'package:flutter/material.dart';
import 'package:tennis_cup/data/matches.dart';
import 'package:tennis_cup/model/player.dart';
import 'package:tennis_cup/model/match.dart';
import 'package:tennis_cup/widgets/comparison_widgets.dart/players_match.dart';

class PlayersMatches extends StatelessWidget {
  final Player player1, player2;
  const PlayersMatches(
      {super.key, required this.player1, required this.player2});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Row(
            children: [
              const Icon(Icons.people),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  "Players' matches: ${player1.fullName} vs ${player2.fullName}",
                  softWrap: true,
                ),
              ),
            ],
          ),
        ),
        for (Match match in matches)
          PlayersMatch(player1: player1, player2: player2, match: match)
      ],
    );
  }
}
