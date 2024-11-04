import 'package:flutter/material.dart';
import 'package:tennis_cup/data/players.dart';
import 'package:tennis_cup/widgets/ranking_panel.dart';
import 'package:tennis_cup/widgets/ranking_player.dart';

class Ranking extends StatefulWidget {
  const Ranking({super.key});

  @override
  State<StatefulWidget> createState() {
    return _Ranking();
  }
}

class _Ranking extends State<Ranking> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const RankingPanel(),
          Expanded(
            child: ListView.builder(
              itemCount: players.length,
              itemBuilder: (ctx, index) => RankingPlayer(
                player: players[index],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
