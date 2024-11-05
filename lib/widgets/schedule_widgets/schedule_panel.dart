import 'package:flutter/material.dart';
import 'package:tennis_cup/data/tournaments.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/widgets/schedule_widgets/schedule_filters.dart';

class SchedulePanel extends StatefulWidget {
  const SchedulePanel({super.key});

  @override
  State<SchedulePanel> createState() {
    return _SchedulePanelState();
  }
}

class _SchedulePanelState extends State<SchedulePanel> {
  Tournament tournament = tournaments[0];
  DateTime selectedDate = DateTime.now();

  void pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2018, 1, 1),
      lastDate: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day + 1),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      selectedDate = pickedDate;
    });
  }

  void showFilters() {
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
              IconButton(
                onPressed: pickDate,
                icon: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.calendar_today),
                    Positioned(
                      top: 6,
                      child: Text(
                        '${selectedDate.day}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: showFilters,
                icon: const Icon(Icons.filter_list),
              )
            ],
          ),
        ],
      ),
    );
  }
}
