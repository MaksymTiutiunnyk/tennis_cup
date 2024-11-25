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
          mainAxisSize: MainAxisSize.min,
          children: [
            const SchedulePanel(),
            Flexible(
              fit: FlexFit.loose,
              child: scheduledTournament.isEmpty
                  ? const Center(child: Text('Tournament is not found'))
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxHeight >= 600) {
                          return Column(
                            children: [
                              ScheduledMatches(
                                tournament: scheduledTournament.first,
                              ),
                              TournamentResults(scheduledTournament.first),
                            ],
                          );
                        }
                        return SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ScheduledMatches(
                                tournament: scheduledTournament.first,
                                isScrollable: false,
                              ),
                              TournamentResults(scheduledTournament.first),
                            ],
                          ),
                        );
                      },
                    ),
            ),
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
