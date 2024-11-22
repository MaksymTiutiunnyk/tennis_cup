import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/providers/upcoming_matches_tournaments_provider.dart';
import 'package:tennis_cup/widgets/home_widgets/upcoming_match.dart';
import 'package:tennis_cup/model/match.dart';

class UpcomingMatches extends ConsumerWidget {
  const UpcomingMatches({super.key});

  List<Match> _getMatchesToDisplay(List<Tournament> tournaments) {
    final List<MapEntry<Match, Tournament>> matchesWithTournaments = [];

    for (final tournament in tournaments) {
      Match? closestUpcomingMatch;
      Duration closestDuration = const Duration(days: 365000);

      for (final match in tournament.matches!) {
        Duration difference = match.dateTime.difference(DateTime.now());
        if (difference > Duration.zero && difference < closestDuration) {
          closestDuration = difference;
          closestUpcomingMatch = match;
        }
      }

      if (closestUpcomingMatch != null) {
        matchesWithTournaments.add(MapEntry(closestUpcomingMatch, tournament));
      }
    }

    matchesWithTournaments
        .sort((a, b) => a.key.dateTime.compareTo(b.key.dateTime));

    tournaments
      ..clear()
      ..addAll(matchesWithTournaments.map((entry) => entry.value));

    return matchesWithTournaments.map((entry) => entry.key).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Tournament>> asyncValue =
        ref.watch(upcomingMatchesTournamentsProvider);

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
                final matches = _getMatchesToDisplay(tournaments);

                if (matches.isEmpty) {
                  return const Center(child: Text('No upcoming matches found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(0),
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    return UpcomingMatch(
                      match: matches[index],
                      tournament: tournaments[index],
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
