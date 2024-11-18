import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/model/match.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/providers/arena_filter_provider.dart';
import 'package:tennis_cup/providers/schedule_date_provider.dart';
import 'package:tennis_cup/providers/tab_index_provider.dart';
import 'package:tennis_cup/providers/time_filter_provider.dart';

DateFormat formatter = DateFormat('yyyy-MM-dd, HH:mm');

class UpcomingMatch extends ConsumerWidget {
  final Match match;
  final Tournament tournament;
  const UpcomingMatch({super.key, required this.match, required this.tournament});

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
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 0, 4),
            child: Row(
              children: [
                Text(
                  formatter.format(match.dateTime),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 8),
                Icon(Icons.circle,
                    color: tournament.arena.color, size: 8),
                const SizedBox(width: 8),
                Text(
                  tournament.arena.title,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 0, 8),
            child: Text(
              '${match.bluePlayer.surname} ${match.bluePlayer.name} - ${match.redPlayer.surname} ${match.redPlayer.name}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
