import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/ui/view_only/home/view_models/upcoming_tournaments_cubit.dart';
import 'package:tennis_cup/ui/view_only/home/widgets/upcoming_match.dart';

class UpcomingMatches extends StatelessWidget {
  final bool isScrollable;
  const UpcomingMatches({super.key, this.isScrollable = true});

  List<MapEntry<Match, Tournament>> _getMatchesToDisplay(List<Tournament> tournaments) {
    final List<MapEntry<Match, Tournament>> matchesWithTournaments = [];

    for (final tournament in tournaments) {
      Match? closestUpcomingMatch;
      Duration closestDuration = const Duration(days: 365000);

      for (final match in tournament.matches ?? []) {
        final difference = match.dateTime.difference(DateTime.now());
        if (difference > Duration.zero && difference < closestDuration) {
          closestDuration = difference;
          closestUpcomingMatch = match;
        }
      }

      if (closestUpcomingMatch != null) {
        matchesWithTournaments.add(MapEntry(closestUpcomingMatch, tournament));
      }
    }

    matchesWithTournaments.sort((a, b) => a.key.dateTime.compareTo(b.key.dateTime));
    return matchesWithTournaments;
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.loose,
      child: Column(
        mainAxisSize: isScrollable ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
            child: BlocBuilder<UpcomingTournamentsCubit, UpcomingTournamentsState>(
              builder: (context, state) => switch (state) {
                UpcomingTournamentsLoading() =>
                  const Center(child: CircularProgressIndicator()),
                UpcomingTournamentsError() =>
                  const Center(child: Text('Ooops, something went wrong')),
                UpcomingTournamentsLoaded(:final tournaments) =>
                  _buildList(tournaments),
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Tournament> tournaments) {
    final entries = _getMatchesToDisplay(tournaments);
    if (entries.isEmpty) {
      return const Center(child: Text('No matches found'));
    }
    return ListView.builder(
      physics: isScrollable ? null : const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: entries.length,
      itemBuilder: (context, index) {
        return UpcomingMatch(
          match: entries[index].key,
          tournament: entries[index].value,
        );
      },
    );
  }
}
