import 'package:flutter/material.dart';
import 'package:tennis_cup/data/tournaments.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/widgets/player_widgets/player_tournament.dart';

class PlayerTournaments extends StatelessWidget {
  const PlayerTournaments({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.emoji_events),
              Text('Tournaments'),
            ],
          ),
          Container(
            height: 300,
            child: ListView.builder(
              itemCount: tournaments.length,
              itemBuilder: (context, index) {
                return PlayerTournament(tournaments[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
