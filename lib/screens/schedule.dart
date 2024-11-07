import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/providers/scheduled_tournament_provider.dart';
import 'package:tennis_cup/widgets/schedule_widgets/schedule_panel.dart';
import 'package:tennis_cup/widgets/schedule_widgets/scheduled_matches.dart';
import 'package:tennis_cup/widgets/schedule_widgets/tournament_results.dart';

class Schedule extends ConsumerWidget {
  const Schedule({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduledTournament = ref.watch(scheduledTournamentProvider);

    return Scaffold(
      body: Column(
        children: [
          SchedulePanel(),
          const ScheduledMatches(),
          TournamentResults(scheduledTournament),
        ],
      ),
    );
  }
}
