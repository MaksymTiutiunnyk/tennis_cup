import 'package:flutter/material.dart';
import 'package:tennis_cup/model/player.dart';

class RankingPlayer extends StatefulWidget {
  final Player player;
  const RankingPlayer({super.key, required this.player});

  @override
  State<RankingPlayer> createState() {
    return _RankingPlayerState();
  }
}

class _RankingPlayerState extends State<RankingPlayer> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/kurtenko_andrii.png'),
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.player.surname} ${widget.player.name}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rank Tennis Cup:',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  (35.6).toString(),
                  style: Theme.of(context).textTheme.bodySmall,
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
                  style: Theme.of(context).textTheme.bodySmall,
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
                  (1).toString(),
                  style: Theme.of(context).textTheme.bodySmall,
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
                  style: Theme.of(context).textTheme.bodySmall,
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
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
