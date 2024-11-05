import 'package:flutter/material.dart';
import 'package:tennis_cup/model/player.dart';

class PlayersComparison extends StatelessWidget {
  final Player player1, player2;
  const PlayersComparison({super.key, required this.player1, required this.player2});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(),
      ),
    );
  }
}
