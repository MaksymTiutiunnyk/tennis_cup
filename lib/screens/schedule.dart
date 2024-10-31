import 'package:flutter/material.dart';
import 'package:tennis_cup/data/tournaments.dart';
import 'package:tennis_cup/widgets/schedule_panel.dart';
import 'package:tennis_cup/widgets/scheduled_matches.dart';
import 'package:tennis_cup/widgets/tournament_results.dart';

class Schedule extends StatelessWidget {
  const Schedule({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SchedulePanel(),
          const ScheduledMatches(),
          TournamentResults(tournaments[0]),
        ],
      ),
    );
  }
}
