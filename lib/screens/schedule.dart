import 'package:flutter/material.dart';
import 'package:tennis_cup/widgets/schedule_panel.dart';
import 'package:tennis_cup/widgets/scheduled_matches.dart';
import 'package:tennis_cup/widgets/tournament_results.dart';

class Schedule extends StatelessWidget {
  const Schedule({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          SchedulePanel(),
          ScheduledMatches(),
          TournamentResults(),
        ],
      ),
    );
  }
}
