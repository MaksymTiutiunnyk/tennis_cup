import 'package:flutter/material.dart';
import 'package:tennis_cup/model/player.dart';
import 'package:tennis_cup/widgets/comparison_widgets.dart/players_intro.dart';
import 'package:tennis_cup/widgets/comparison_widgets.dart/players_matches.dart';
import 'package:tennis_cup/widgets/comparison_widgets.dart/players_statistics.dart';

class PlayersComparison extends StatelessWidget {
  final Player player1, player2;
  const PlayersComparison(
      {super.key, required this.player1, required this.player2});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 35,
        title: const Text('Tennis Cup: Players comparison'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PlayersIntro(player1: player1, player2: player2),
            PlayersStatistics(player1: player1, player2: player2),
            PlayersMatches(player1: player1, player2: player2),
          ],
        ),
      ),
    );
  }
}
