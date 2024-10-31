import 'package:flutter/material.dart';
import 'package:tennis_cup/model/match.dart';
import 'package:intl/intl.dart';

DateFormat formatter = DateFormat('yyyy-MM-dd hh:mm');

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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            formatter.format(match.dateTime!),
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.circle, color: match.arena.color, size: 10),
              const SizedBox(width: 8),
              Text(
                match.arena.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '${match.bluePlayer.surname} ${match.bluePlayer.name} - ${match.redPlayer.surname} ${match.redPlayer.name}',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
