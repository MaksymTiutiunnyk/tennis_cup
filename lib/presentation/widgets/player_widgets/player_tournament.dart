import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/presentation/screens/tabs.dart';

DateFormat formatter = DateFormat('yyyy-MM-dd');

class PlayerTournament extends StatelessWidget {
  final Tournament tournament;
  final Player player;
  const PlayerTournament(
      {required this.player, required this.tournament, super.key});

  String _getSetsRatio() {
    int setsWon = 0;
    int setsLost = 0;

    for (final match in tournament.matches!) {
      if (match.bluePlayer == player) {
        setsWon += match.blueScore;
        setsLost += match.redScore;
      } else if (match.redPlayer == player) {
        setsWon += match.redScore;
        setsLost += match.blueScore;
      }
    }

    return '$setsWon : $setsLost';
  }

  int _getWins() {
    int wins = 0;
    for (final match in tournament.matches!) {
      if (match.bluePlayer == player && match.blueScore == 3) {
        wins++;
      } else if (match.redPlayer == player && match.redScore == 3) {
        wins++;
      }
    }
    return wins;
  }

  int _getLoses() {
    int loses = 0;
    for (final match in tournament.matches!) {
      if (match.bluePlayer == player && match.redScore == 3) {
        loses++;
      } else if (match.redPlayer == player && match.blueScore == 3) {
        loses++;
      }
    }
    return loses;
  }

  @override
  Widget build(BuildContext context) {
    int index = tournament.players.indexOf(player);

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<Tabs>(
            builder: (ctx) => Tabs(
              initialTabIndex: 1,
              initialDate: tournament.date,
              initialArena: tournament.arena,
              initialTime: tournament.time,
            ),
          ),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: tournament.isFinished
                        ? Colors.grey
                        : Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${formatter.format(tournament.date)} ${tournament.players[0].sex.name}, ${tournament.time.name} ${tournament.arena.title}',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Position:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    tournament.places[index].toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Wins:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    _getWins().toString(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Loses:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    _getLoses().toString(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sets ratio:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    _getSetsRatio().toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Points:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    tournament.points[index].toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
