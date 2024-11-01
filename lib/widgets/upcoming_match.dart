import 'package:flutter/material.dart';
import 'package:tennis_cup/model/match.dart';
import 'package:intl/intl.dart';

DateFormat formatter = DateFormat('yyyy-MM-dd, HH:mm');

class UpcomingMatch extends StatelessWidget {
  final Match match;
  const UpcomingMatch({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 0, 4),
          child: Row(
            children: [
              Text(
                formatter.format(match.dateTime),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 8),
              Icon(Icons.circle, color: match.tournament.arena.color, size: 8),
              const SizedBox(width: 8),
              Text(
                match.tournament.arena.title,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 0, 8),
          child: Text(
            '${match.bluePlayer.surname} ${match.bluePlayer.name} - ${match.redPlayer.surname} ${match.redPlayer.name}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
