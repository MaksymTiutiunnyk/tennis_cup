import 'package:flutter/material.dart';
import 'package:tennis_cup/widgets/upcoming_match.dart';
import 'package:tennis_cup/data/matches.dart';

class UpcomingMatches extends StatelessWidget {
  const UpcomingMatches({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 8),
                Text(
                  'Tennis Cup: Upcoming matches',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(0),
              itemCount: 6,
              itemBuilder: (context, index) {
                return UpcomingMatch(match: matches[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
