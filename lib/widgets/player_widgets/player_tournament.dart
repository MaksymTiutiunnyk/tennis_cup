import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/model/tournament.dart';

DateFormat formatter = DateFormat('yyyy-MM-dd');

class PlayerTournament extends StatefulWidget {
  final Tournament tournament;
  const PlayerTournament(this.tournament, {super.key});

  @override
  State<PlayerTournament> createState() {
    return _PlayerTournamentState();
  }
}

class _PlayerTournamentState extends State<PlayerTournament> {
  Widget buildDataRow(String leftPart, String rightPart) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          leftPart,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          rightPart,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatter.format(widget.tournament.date),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Row(
              children: [
                const Icon(Icons.emoji_events),
                const SizedBox(width: 8),
                Text(widget.tournament.title),
              ],
            ),
            const SizedBox(height: 8),
            buildDataRow('Position:', 1.toString()),
            const SizedBox(height: 4),
            buildDataRow('Wins:', 5.toString()),
            const SizedBox(height: 4),
            buildDataRow('Loses:', 0.toString()),
            const SizedBox(height: 4),
            buildDataRow('Sets ratio:', '15:0'),
            const SizedBox(height: 4),
            buildDataRow('Points:', 10.toString()),
          ],
        ),
      ),
    );
  }
}
