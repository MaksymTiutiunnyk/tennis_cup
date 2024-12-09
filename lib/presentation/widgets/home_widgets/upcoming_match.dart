import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/logic/cubit/arena_filter_cubit.dart';
import 'package:tennis_cup/logic/cubit/schedule_date_cubit.dart';
import 'package:tennis_cup/logic/cubit/tab_index_cubit.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/logic/cubit/time_filter_cubit.dart';

DateFormat formatter = DateFormat('yyyy-MM-dd, HH:mm');

class UpcomingMatch extends StatelessWidget {
  final Match match;
  final Tournament tournament;
  const UpcomingMatch(
      {super.key, required this.match, required this.tournament});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<ScheduleDateCubit>().selectDate(tournament.date);
        context.read<TimeFilterCubit>().selectTime(tournament.time);
        context.read<ArenaFilterCubit>().selectArena(tournament.arena);
        context.read<TabIndexCubit>().selectTab(1);
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
                Icon(Icons.circle, color: tournament.arena.color, size: 8),
                const SizedBox(width: 8),
                Text(
                  tournament.arena.title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(fontSize: 13),
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
