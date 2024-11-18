import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/model/player.dart';
import 'package:tennis_cup/model/match.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/providers/arena_filter_provider.dart';
import 'package:tennis_cup/providers/schedule_date_provider.dart';
import 'package:tennis_cup/providers/tab_index_provider.dart';
import 'package:tennis_cup/providers/time_filter_provider.dart';
import 'package:tennis_cup/screens/tabs.dart';

DateFormat formatter = DateFormat('yyyy-MM-dd, HH:mm');

class PlayersMatch extends ConsumerWidget {
  final Player player1, player2;
  final Match match;
  final Tournament tournament;
  const PlayersMatch({
    super.key,
    required this.player1,
    required this.player2,
    required this.match,
    required this.tournament,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        ref
            .read(scheduleDateProvider.notifier)
            .selectDate(tournament.date);
        ref.read(timeFilterProvider.notifier).selectTime(tournament.time);
        ref
            .read(arenaFilterProvider.notifier)
            .selectArena(tournament.arena);
        ref.read(tabIndexProvider.notifier).selectTab(1);

        Navigator.of(context)
            .push(MaterialPageRoute(builder: (ctx) => const Tabs()));
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatter.format(match.dateTime),
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
              Text(
                '${match.blueScore} : ${match.redScore}',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                '${match.blueSetScores}, ${match.redSetScores}',
                // '(${match.blueSetScores[0]} : ${match.redSetScores[0]}, ${match.blueSetScores[1]} : ${match.redSetScores[1]}, ${match.blueSetScores[2]} : ${match.redSetScores[2]}, ${match.blueSetScores[3]} : ${match.redSetScores[3]}, ${match.blueSetScores[4]} : ${match.redSetScores[4]}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
