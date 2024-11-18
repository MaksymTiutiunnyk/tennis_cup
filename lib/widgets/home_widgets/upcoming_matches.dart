import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/providers/live_stream_and_upcoming_matches_tournaments_provider.dart';
import 'package:tennis_cup/widgets/home_widgets/upcoming_match.dart';

class UpcomingMatches extends ConsumerWidget {
  const UpcomingMatches({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Tournament>> asyncValue =
        ref.watch(liveStreamAndUpcomingMatchesTournamentsProvider);

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 8),
                Text(
                  'Tennis Cup: Upcoming matches',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          Expanded(
            child: asyncValue.when(
              data: (tournaments) {
                return ListView.builder(
                  padding: const EdgeInsets.all(0),
                  itemCount: tournaments.first.matches!.length,
                  itemBuilder: (context, index) {
                    return UpcomingMatch(
                      match: tournaments.first.matches![index],
                      tournament: tournaments.first,
                    );
                  },
                );
              },
              error: (error, stackTrace) => Center(
                child: Text('error $error'),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
