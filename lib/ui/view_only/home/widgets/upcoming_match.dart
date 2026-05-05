import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/match_view.dart';
import 'package:tennis_cup/routing/app_router.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/arena_filter_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/schedule_date_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/time_filter_cubit.dart';

final _formatter = DateFormat('yyyy-MM-dd, HH:mm');

class UpcomingMatch extends StatelessWidget {
  final MatchView match;
  const UpcomingMatch({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<ScheduleDateCubit>().selectDate(match.tournamentStart);
        context.read<TimeFilterCubit>().selectTime(match.tournamentTime);
        context.read<ArenaFilterCubit>().selectArena(Arena(
              id: match.arenaId,
              title: match.arenaName,
              color: Colors.grey,
            ));
        context.go(AppRoutes.viewSchedule);
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
                  _formatter.format(match.tournamentStart),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 8),
                const Icon(Icons.circle, color: Colors.grey, size: 8),
                const SizedBox(width: 8),
                Text(
                  match.arenaName,
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
