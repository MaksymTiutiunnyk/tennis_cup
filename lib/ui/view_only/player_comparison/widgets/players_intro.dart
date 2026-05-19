import 'package:flutter/material.dart';
import 'package:tennis_cup/data/models/user.dart';
import 'package:tennis_cup/ui/view_only/player_comparison/widgets/player_intro.dart';

class PlayersIntro extends StatelessWidget {
  final User player1, player2;
  const PlayersIntro({super.key, required this.player1, required this.player2});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PlayerIntro(player1),
              PlayerIntro(player2),
            ],
          ),
        ),
        Positioned(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .shadow
                      .withValues(alpha: 0.25),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              child: const Text('VS'),
            ),
          ),
        )
      ],
    );
  }
}
