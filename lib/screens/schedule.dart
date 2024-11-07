import 'package:flutter/material.dart';
import 'package:tennis_cup/data/tournaments.dart';
import 'package:tennis_cup/widgets/schedule_widgets/schedule_panel.dart';
import 'package:tennis_cup/widgets/schedule_widgets/scheduled_matches.dart';
import 'package:tennis_cup/widgets/schedule_widgets/tournament_results.dart';

class Schedule extends StatelessWidget {
  const Schedule({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SchedulePanel(),
          const ScheduledMatches(),
          TournamentResults(tournaments[0]),
        ],
      ),
    );
  }
}
