import 'package:flutter/material.dart';
import 'package:tennis_cup/model/arena.dart';
import 'package:tennis_cup/model/player.dart';
import 'package:tennis_cup/model/match.dart';
import 'package:tennis_cup/widgets/upcoming_match.dart';

final List<Match> matches = [
  Match(
    bluePlayer: Player(name: 'Vasyl', surname: 'Smyk'),
    redPlayer: Player(name: 'Andrii', surname: 'Kurtenko'),
    arena: Arena(title: 'America', color: Colors.black),
    dateTime: DateTime(2024, 10, 28, 11, 35),
  ),
  Match(
    bluePlayer: Player(name: 'Volodymyr', surname: 'Ivasiv'),
    redPlayer: Player(name: 'Mykola', surname: 'Slozka'),
    arena: Arena(title: 'Beijing', color: Colors.purple),
    dateTime: DateTime(2024, 10, 28, 11, 35),
  ),
  Match(
    bluePlayer: Player(name: 'Olena', surname: 'Telezhynska'),
    redPlayer: Player(name: 'Svitlana', surname: 'Yureneva'),
    arena: Arena(title: 'Australia', color: Colors.green),
    dateTime: DateTime(2024, 10, 28, 11, 50),
  ),
];

class UpcomingMatches extends StatelessWidget {
  const UpcomingMatches({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Color.fromARGB(255, 1, 1, 98),
                ),
                SizedBox(width: 8),
                Text(
                  'Tennis Cup: Upcoming matches',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(0),
              itemCount: matches.length,
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
