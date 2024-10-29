import 'package:flutter/material.dart';
import 'package:tennis_cup/model/match.dart';

class UpcomingMatch extends StatelessWidget {
  final Match match;
  const UpcomingMatch({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            match.dateTime.toString(),
            style: const TextStyle(color: Colors.grey),
          ),
          Row(
            children: [
              Icon(Icons.circle, color: match.arena.color, size: 10),
              const SizedBox(width: 8),
              Text(
                match.arena.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${match.bluePlayer.surname} ${match.bluePlayer.name} - ${match.redPlayer.surname} ${match.redPlayer.name}',
            style: const TextStyle(fontSize: 16),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
