import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/providers/scheduled_tournament_provider.dart';
import 'package:tennis_cup/widgets/schedule_widgets/schedule_panel.dart';
import 'package:tennis_cup/widgets/schedule_widgets/scheduled_matches.dart';
import 'package:tennis_cup/widgets/schedule_widgets/tournament_results.dart';

class Schedule extends ConsumerWidget {
  const Schedule({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Tournament>> scheduledTournament =
        ref.watch(scheduledTournamentProvider);

    return Scaffold(
      body: scheduledTournament.when(
        data: (scheduledTournament) => Column(
          children: [
            const SchedulePanel(),
            if (scheduledTournament.isEmpty)
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text('Tournament is not found'),
                    ),
                  ],
                ),
              ),
            if (scheduledTournament.isNotEmpty)
              ScheduledMatches(tournament: scheduledTournament.first),
            if (scheduledTournament.isNotEmpty)
              TournamentResults(scheduledTournament.first),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          return const Center(child: Text('Ooops, something went wrong'));
        },
      ),
    );
  }
}
