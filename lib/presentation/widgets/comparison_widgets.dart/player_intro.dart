import 'package:flutter/material.dart';
import 'package:tennis_cup/custom_icons_icons.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/presentation/screens/player_details.dart';

class PlayerIntro extends StatelessWidget {
  final Player player;
  const PlayerIntro(this.player, {super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => PlayerDetails(player: player)));
        },
        child: Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 8),
                CircleAvatar(
                  radius: 50,
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
                const SizedBox(height: 8),
                Text(
                  player.fullName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CustomIcons.medal,
                            size: 16,
                            color: Colors.yellow.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(player.gold.toString()),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            CustomIcons.medal,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(player.silver.toString()),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CustomIcons.medal,
                            size: 16,
                            color: Colors.yellow.shade900,
                          ),
                          const SizedBox(width: 4),
                          Text(player.bronze.toString()),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
