import 'package:flutter/material.dart';
import 'package:tennis_cup/data/tournaments.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/widgets/schedule_widgets/schedule_date_picker.dart';
import 'package:tennis_cup/widgets/schedule_widgets/schedule_filters.dart';

class SchedulePanel extends StatelessWidget {
  SchedulePanel({super.key});

  final Tournament tournament = tournaments[0];

  void showFilters(BuildContext context) {
    showModalBottomSheet(
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const ScheduleFilters(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  backgroundColor: tournament.arena.color,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Arena: ${tournament.arena.title}\n${tournament.title}',
                style: Theme.of(context).textTheme.bodyMedium,
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
