import 'package:flutter/material.dart';
import 'package:tennis_cup/data/data_providers/tournament_api.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/repositories/tournament_repository.dart';
import 'package:tennis_cup/presentation/widgets/home_widgets/live_stream_match.dart';
import 'package:tennis_cup/data/models/match.dart';

class LiveStreamMatches extends StatelessWidget {
  final tournamentRepository =
      const TournamentRepository(tournamentApi: TournamentApi());

  final bool isScreenWide;
  const LiveStreamMatches({super.key, this.isScreenWide = false});

  List<Match> _getMatchesToDisplay(List<Tournament> tournaments) {
    final List<MapEntry<Match, Tournament>> matchesWithTournaments = [];

    for (final tournament in tournaments) {
      Match? closestMatch;
      Duration closestDuration = const Duration(days: 365000);

      for (final match in tournament.matches!) {
        Duration difference = match.dateTime.difference(DateTime.now()).abs();
        if (difference < closestDuration) {
          closestDuration = difference;
          closestMatch = match;
        }
      }

      if (closestMatch != null) {
        matchesWithTournaments.add(MapEntry(closestMatch, tournament));
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
    final liveStreamMatchesTournaments =
        tournamentRepository.fetchLiveStreamMatchesTournaments();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.live_tv),
              const SizedBox(width: 8),
              Text(
                'Tennis Cup: Live stream',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        SizedBox(
          height: isScreenWide ? 220 : 170,
          child: FutureBuilder(
            future: liveStreamMatchesTournaments,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData) {
                if (snapshot.data!.isEmpty) {
                  return const Center(child: Text('No matches found'));
                }
                final tournaments = snapshot.data!;
                final matches = _getMatchesToDisplay(tournaments);

                return PageView.builder(
                  scrollDirection:
                      isScreenWide ? Axis.vertical : Axis.horizontal,
                  controller: PageController(viewportFraction: 0.90),
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    return LiveStreamMatch(
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
    );
  }
}
