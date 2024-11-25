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
              CircleAvatar(
                radius: 20,
                child: ClipOval(
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/default_avatar.jpg',
                    image: player.imageUrl,
                    fit: BoxFit.cover,
                    imageErrorBuilder: (context, error, stackTrace) =>
                        Image.asset(
                      'assets/default_avatar.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                player.fullName,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          Text(
            score.toString(),
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
