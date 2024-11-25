import 'package:flutter/material.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/repositories/tournament_repository.dart';
import 'package:tennis_cup/widgets/home_widgets/upcoming_match.dart';
import 'package:tennis_cup/model/match.dart';

class UpcomingMatches extends StatelessWidget {
  final bool isBetween;
  const UpcomingMatches({super.key, this.isBetween = true});

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
  Widget build(BuildContext context) {
    final upcomingMatchesTournaments =
        TournamentRepository.fetchUpcomingMatchesTournaments();

    return Flexible(
      fit: FlexFit.loose,
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
          Flexible(
            fit: FlexFit.loose,
            child: FutureBuilder(
              future: upcomingMatchesTournaments,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData) {
                  final tournaments = snapshot.data!;
                  final matches = _getMatchesToDisplay(tournaments);

                  if (matches.isEmpty) {
                    return const Center(child: Text('No matches found'));
                  }

                  return ListView.builder(
                    physics:
                        isBetween ? null : const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: matches.length,
                    itemBuilder: (context, index) {
                      return UpcomingMatch(
                        match: matches[index],
                        tournament: tournaments[index],
                      );
                    },
                  );
                }
                return const Center(child: Text('Ooops, something went wrong'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
