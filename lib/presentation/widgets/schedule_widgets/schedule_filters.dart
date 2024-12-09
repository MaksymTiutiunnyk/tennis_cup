import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/data_providers/arenas.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/logic/cubit/arena_filter_cubit.dart';
import 'package:tennis_cup/logic/cubit/time_filter_cubit.dart';

class ScheduleFilters extends StatelessWidget {
  const ScheduleFilters({super.key});

  @override
  Widget build(BuildContext context) {
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
                    'Filters',
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
                child: const Text('Apply'),
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
                        Text(time.name),
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
            child: BlocBuilder<ArenaFilterCubit, Arena>(
              builder: (context, state) => ListView(
                children: [
                  for (Arena arena in arenas)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.circle,
                              color: arena.color,
                              size: 10,
                            ),
                            const SizedBox(width: 8),
                            Text('Arena: ${arena.title}'),
                          ],
                        ),
                        Radio<Arena>(
                          value: arena,
                          groupValue: state,
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
          ),
        ),
      ],
    );
  }
}
