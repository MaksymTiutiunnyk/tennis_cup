import 'package:flutter/material.dart';
import 'package:tennis_cup/data/tournaments.dart';
import 'package:tennis_cup/model/tournament.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 215, 215, 215),
      padding: const EdgeInsets.all(16),
      child: Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: CircleAvatar(
                    radius: 6,
                    backgroundColor: tournament.arena.color,
                  ),
                ),
                const SizedBox(width: 8),
                Text('Arena: ${tournament.arena.title}\n${tournament.title}'),
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
                            color: Color.fromARGB(255, 4, 30, 75),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_alt),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
