import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/data/data_providers/arenas.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/logic/riverpod/arena_filter_provider.dart';
import 'package:tennis_cup/logic/riverpod/time_filter_provider.dart';

class ScheduleFilters extends ConsumerWidget {
  const ScheduleFilters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Time selectedTime = ref.watch(timeFilterProvider);
    Arena selectedArena = ref.watch(arenaFilterProvider);

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
            child: ListView(
              children: [
                for (Time time in Time.values)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(time.name),
                      Radio<Time>(
                        value: time,
                        groupValue: selectedTime,
                        onChanged: (value) {
                          ref
                              .read(timeFilterProvider.notifier)
                              .selectTime(value!);
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: ListView(
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
                        groupValue: selectedArena,
                        onChanged: (value) {
                          ref
                              .read(arenaFilterProvider.notifier)
                              .selectArena(value!);
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
