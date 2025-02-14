import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/presentation/screens/player_details.dart';
import 'package:tennis_cup/presentation/screens/players_comparison.dart';

DateFormat formatter = DateFormat('HH:mm');

class ScheduledMatch extends StatelessWidget {
  final Match match;
  const ScheduledMatch({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatter.format(match.dateTime),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<PlayersComparison>(
                          builder: (ctx) => PlayersComparison(
                            player1: match.bluePlayer,
                            player2: match.redPlayer,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.people),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute<PlayerDetails>(
                          builder: (ctx) =>
                              PlayerDetails(player: match.bluePlayer)));
                    },
                    child: Text(
                      match.bluePlayer.fullName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Text(
                      match.blueScore.toString(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute<PlayerDetails>(
                          builder: (ctx) =>
                              PlayerDetails(player: match.redPlayer)));
                    },
                    child: Text(
                      match.redPlayer.fullName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Text(
                      match.redScore.toString(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 2),
      ],
    );
  }
}
