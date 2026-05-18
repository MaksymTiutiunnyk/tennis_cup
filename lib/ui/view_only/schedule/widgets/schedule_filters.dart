import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/ui/core/themes/color_utils.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/arena_filter_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/arenas_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/time_filter_cubit.dart';

class ScheduleFilters extends StatelessWidget {
  const ScheduleFilters({super.key});

  String _timeLabel(S s, Time t) => switch (t) {
        Time.Morning => s.timeLabelMorning,
        Time.Day => s.timeLabelDay,
        Time.Evening => s.timeLabelEvening,
        Time.Night => s.timeLabelNight,
        Time.Midnight => s.timeLabelMidnight,
      };

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.filter_list),
                  const SizedBox(width: 8),
                  Text(
                    s.filters,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(s.apply),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: BlocBuilder<TimeFilterCubit, Time>(
              builder: (context, state) => ListView(
                children: [
                  for (Time time in Time.values)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_timeLabel(s, time)),
                        Radio<Time>(
                          value: time,
                          groupValue: state,
                          onChanged: (value) {
                            context.read<TimeFilterCubit>().selectTime(value!);
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: BlocBuilder<ArenasCubit, ArenasState>(
              builder: (context, arenasState) => switch (arenasState) {
                ArenasLoading() =>
                  const Center(child: CircularProgressIndicator()),
                ArenasError() =>
                  Center(child: Text(s.arenasNotFound)),
                ArenasLoaded(:final arenas) when arenas.isEmpty =>
                  Center(child: Text(s.arenasNotFound)),
                ArenasLoaded(:final arenas) =>
                  BlocBuilder<ArenaFilterCubit, Arena>(
                    builder: (context, selected) => ListView(
                      children: [
                        for (Arena arena in arenas)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: arenaColorToMaterial(arena.color),
                                    size: 10,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(s.arenaFilter(arena.title)),
                                ],
                              ),
                              Radio<Arena>(
                                value: arena,
                                groupValue: selected,
                                onChanged: (value) {
                                  context
                                      .read<ArenaFilterCubit>()
                                      .selectArena(value!);
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
              },
            ),
          ),
        ),
      ],
    );
  }
}
