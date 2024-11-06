import 'package:flutter/material.dart';
import 'package:tennis_cup/model/player.dart';
import 'package:tennis_cup/widgets/comparison_widgets.dart/player_intro.dart';

class PlayersIntro extends StatelessWidget {
  final Player player1, player2;
  const PlayersIntro({super.key, required this.player1, required this.player2});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        PlayerIntro(player1),
        PlayerIntro(player2),
      ],
    );
  }
}
