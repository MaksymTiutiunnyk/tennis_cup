import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_cup/data/models/user.dart';
import 'package:tennis_cup/routing/app_router.dart';
import 'package:tennis_cup/ui/core/icons/custom_icons_icons.dart';
import 'package:tennis_cup/ui/core/widgets/player_avatar.dart';

class PlayerIntro extends StatelessWidget {
  final User player;
  const PlayerIntro(this.player, {super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () => context.push(
          AppRoutes.playerDetails(player.id.toString()),
        ),
        child: Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 8),
                PlayerAvatar(imageUrl: player.imageUrl, radius: 50),
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
                          Text(player.goldPlaces.toString()),
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
                          Text(player.silverPlaces.toString()),
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
                          Text(player.bronzePlaces.toString()),
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
