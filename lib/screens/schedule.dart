import 'package:flutter/material.dart';
import 'package:tennis_cup/widgets/schedule_panel.dart';
import 'package:tennis_cup/widgets/scheduled_matches.dart';

class Schedule extends StatelessWidget {
  const Schedule({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SchedulePanel(),
          ScheduledMatches(),
        ],
      ),
    );
  }
}
