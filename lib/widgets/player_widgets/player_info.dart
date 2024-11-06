import 'package:flutter/material.dart';
import 'package:tennis_cup/model/player.dart';

class PlayerInfo extends StatelessWidget {
  final Player player;
  const PlayerInfo(this.player, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          const SizedBox(height: 8),
          const CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(
                'https://tabletennis.setkacup.com/api/Image/setka/480x480/Mi8yMy8yMzA5L2ltYWdlLmpwZw==.jpeg'),
          ),
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
                      (35.6).toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rank UTTF:',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      (35.6).toString(),
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
                      1.toString(),
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
                      'Kyiv, Ukraine',
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
                      1995.toString(),
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
                      300.toString(),
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
                      231.toString(),
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
