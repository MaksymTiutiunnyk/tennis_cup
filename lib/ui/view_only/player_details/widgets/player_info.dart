import 'package:flutter/material.dart';
import 'package:tennis_cup/data/models/user.dart';
import 'package:tennis_cup/ui/core/widgets/player_avatar.dart';

class PlayerInfo extends StatelessWidget {
  final User player;
  const PlayerInfo(this.player, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          const SizedBox(height: 8),
          PlayerAvatar(imageUrl: player.imageUrl, radius: 60),
          const SizedBox(height: 8),
          Text(
            player.fullName,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rank Tennis Cup:',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      player.rating.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tournaments:',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      player.tournaments.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const Divider(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'City, Country:',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      player.place,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Year of birth:',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      player.year.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Wins:',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      player.wins.toString(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Loses:',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      player.losses.toString(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
