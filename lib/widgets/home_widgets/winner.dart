import 'package:flutter/material.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:intl/intl.dart';

DateFormat formatter = DateFormat('yyyy-MM-dd');

class Winner extends StatelessWidget {
  final Tournament tournament;
  const Winner({super.key, required this.tournament});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage('assets/kurtenko_andrii.png'),
          ),
          const SizedBox(height: 8),
          Text(
            'Kurtenko Andrii',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, color: Colors.orange, size: 24),
              const SizedBox(width: 8),
              Text(
                'Men, ${tournament.time.name}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tournament.arena.title,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey),
                ),
                Text(
                  formatter.format(tournament.date),
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}