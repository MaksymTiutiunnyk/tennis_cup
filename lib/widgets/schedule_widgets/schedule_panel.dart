import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/model/arena.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/providers/arena_filter_provider.dart';
import 'package:tennis_cup/providers/schedule_date_provider.dart';
import 'package:tennis_cup/providers/time_filter_provider.dart';
import 'package:tennis_cup/widgets/schedule_widgets/schedule_date_picker.dart';
import 'package:tennis_cup/widgets/schedule_widgets/schedule_filters.dart';

DateFormat formatter = DateFormat('yyyy-MM-dd');

class SchedulePanel extends ConsumerWidget {
  const SchedulePanel({super.key});

  void showFilters(BuildContext context) {
    showModalBottomSheet(
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const ScheduleFilters(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime tournamentDate = ref.watch(scheduleDateProvider);
    final Arena tournamentArena = ref.watch(arenaFilterProvider);
    final Time tournamentTime = ref.watch(timeFilterProvider);

    return Container(
      color: const Color.fromARGB(255, 237, 235, 235),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: CircleAvatar(
                  radius: 5,
                  backgroundColor: tournamentArena.color,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Arena: ${tournamentArena.title}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '${formatter.format(tournamentDate)} ${tournamentTime.name}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              const ScheduleDatePicker(),
              IconButton(
                onPressed: () {
                  showFilters(context);
                },
                icon: const Icon(Icons.filter_list),
              )
            ],
          ),
        ],
      ),
    );
  }
}
