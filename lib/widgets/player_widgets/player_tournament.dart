import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/model/player.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/providers/arena_filter_provider.dart';
import 'package:tennis_cup/providers/schedule_date_provider.dart';
import 'package:tennis_cup/providers/tab_index_provider.dart';
import 'package:tennis_cup/providers/time_filter_provider.dart';
import 'package:tennis_cup/screens/tabs.dart';

DateFormat formatter = DateFormat('yyyy-MM-dd');

class PlayerTournament extends ConsumerWidget {
  final Tournament tournament;
  final Player player;
  const PlayerTournament(
      {required this.player, required this.tournament, super.key});

  int _definePlayerIndex() {
    return tournament.players.indexOf(player);
  }

  String _getSetsRatio() {
    int setsWon = 0;
    int setsLost = 0;

    for (var match in tournament.matches!) {
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

  Widget buildDataRow(BuildContext context, String leftPart, String rightPart) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          leftPart,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          rightPart,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int index = _definePlayerIndex();

    return InkWell(
      onTap: () {
        ref.read(scheduleDateProvider.notifier).selectDate(tournament.date);
        ref.read(timeFilterProvider.notifier).selectTime(tournament.time);
        ref.read(arenaFilterProvider.notifier).selectArena(tournament.arena);
        ref.read(tabIndexProvider.notifier).selectTab(1);

        Navigator.of(context)
            .push(MaterialPageRoute(builder: (ctx) => const Tabs()));
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatter.format(tournament.date),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Row(
                children: [
                  const Icon(Icons.emoji_events),
                  const SizedBox(width: 8),
                  Text(tournament.title),
                ],
              ),
              const SizedBox(height: 8),
              buildDataRow(
                  context, 'Position:', tournament.places[index].toString()),
              const SizedBox(height: 4),
              buildDataRow(
                  context, 'Wins:', (tournament.points[index] - 5).toString()),
              const SizedBox(height: 4),
              buildDataRow(context, 'Loses:',
                  (10 - tournament.points[index]).toString()),
              const SizedBox(height: 4),
              buildDataRow(context, 'Sets ratio:', _getSetsRatio()),
              const SizedBox(height: 4),
              buildDataRow(
                  context, 'Points:', tournament.points[index].toString()),
            ],
          ),
        ),
      ),
    );
  }
}
