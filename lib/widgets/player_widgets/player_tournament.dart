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
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(formatter.format(widget.tournament.date)),
          Row(
            children: [
              const Icon(Icons.emoji_events),
              const SizedBox(width: 8),
              Text(widget.tournament.title),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Position:'),
              Text(1.toString()),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Wins:'),
              Text(5.toString()),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Loses:'),
              Text(0.toString()),
            ],
          ),
          const SizedBox(height: 4),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sets ratio:'),
              Text('15:0'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Points:'),
              Text(10.toString()),
            ],
          ),
        ],
      ),
    );
  }
}
