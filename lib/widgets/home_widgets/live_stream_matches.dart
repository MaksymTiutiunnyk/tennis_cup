import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/providers/live_stream_and_upcoming_matches_tournaments_provider.dart';
import 'package:tennis_cup/widgets/home_widgets/live_stream_match.dart';
import 'package:tennis_cup/model/match.dart';

class LiveStreamMatches extends ConsumerWidget {
  const LiveStreamMatches({super.key});

  List<Match> _getMatchesToDisplay(List<Tournament> tournaments) {
    final List<Match> matches = [];

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
        matches.add(closestMatch);
      }
    }
    return matches;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Tournament>> asyncValue =
        ref.watch(liveStreamAndUpcomingMatchesTournamentsProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
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
          height: 170,
          child: asyncValue.when(
            data: (tournaments) {
              final matches = _getMatchesToDisplay(tournaments);

              return PageView.builder(
                scrollDirection: Axis.horizontal,
                controller: PageController(viewportFraction: 0.90),
                itemCount: matches.length,
                itemBuilder: (context, index) {
                  return LiveStreamMatch(
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
    );
  }
}
