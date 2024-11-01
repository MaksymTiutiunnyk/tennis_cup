import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tennis_cup/data/arenas.dart';
import 'package:tennis_cup/model/arena.dart';
import 'package:tennis_cup/model/tournament.dart';

class ScheduleFilters extends StatefulWidget {
  const ScheduleFilters({super.key});

  @override
  State<ScheduleFilters> createState() => _ScheduleFiltersState();
}

class _ScheduleFiltersState extends State<ScheduleFilters> {
  Time? _time = Time.morning;
  Arena? _arena = arenas[0];

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
            child: ListView(
              children: [
                for (Time time in Time.values)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(time.name),
                      Radio<Time>(
                        value: time,
                        groupValue: _time,
                        onChanged: (value) {
                          setState(() {
                            _time = value;
                          });
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
                        groupValue: _arena,
                        onChanged: (value) {
                          setState(() {
                            _arena = value;
                          });
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
