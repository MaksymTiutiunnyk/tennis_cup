import 'package:flutter/material.dart';
import 'package:tennis_cup/model/player.dart';
import 'package:tennis_cup/model/match.dart';
import 'package:intl/intl.dart';

DateFormat formatter = DateFormat('yyyy-MM-dd, HH:mm');

class PlayersMatch extends StatefulWidget {
  final Player player1, player2;
  final Match match;
  const PlayersMatch(
      {super.key,
      required this.player1,
      required this.player2,
      required this.match});

  @override
  State<PlayersMatch> createState() {
    return _PlayersMatchState();
  }
}

class _PlayersMatchState extends State<PlayersMatch> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatter.format(widget.match.dateTime),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Row(
              children: [
                const Icon(Icons.emoji_events),
                const SizedBox(width: 8),
                Text(widget.match.tournament.title),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '0 : 3',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              '(7-11, 2-11, 9-11)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
