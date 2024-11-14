import 'package:flutter/material.dart';
import 'package:tennis_cup/model/player.dart';
import 'package:tennis_cup/screens/player_details.dart';

class LiveStreamMatchPlayer extends StatelessWidget {
  final Player player;
  final int score;

  const LiveStreamMatchPlayer(
      {required this.player, required this.score, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => PlayerDetails(player: player)));
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage("assets/kurtenko_andrii.png"),
              ),
              const SizedBox(width: 8),
              Text(
                player.fullName,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Colors.white),
              ),
            ],
          ),
          Text(
            score.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
