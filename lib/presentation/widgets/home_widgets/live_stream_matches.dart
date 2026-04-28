import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/logic/cubit/live_stream_match_index_cubit.dart';
import 'package:tennis_cup/logic/cubit/live_stream_tournaments_cubit.dart';
import 'package:tennis_cup/presentation/widgets/home_widgets/live_stream_match.dart';

class LiveStreamMatches extends StatelessWidget {
  final bool isScreenWide;
  const LiveStreamMatches({super.key, this.isScreenWide = false});

  List<Match> _getMatchesToDisplay(List<Tournament> tournaments) {
    final List<MapEntry<Match, Tournament>> matchesWithTournaments = [];

    for (final tournament in tournaments) {
      Match? closestMatch;
      Duration closestDuration = const Duration(days: 365000);

      for (final match in tournament.matches ?? []) {
        final difference = match.dateTime.difference(DateTime.now()).abs();
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
          height: isScreenWide ? 220 : 200,
          child: BlocBuilder<LiveStreamTournamentsCubit,
              LiveStreamTournamentsState>(
            builder: (context, state) => switch (state) {
              LiveStreamTournamentsLoading() =>
                const Center(child: CircularProgressIndicator()),
              LiveStreamTournamentsError() =>
                const Center(child: Text('Ooops, something went wrong')),
              LiveStreamTournamentsLoaded(:final tournaments) =>
                _buildContent(context, tournaments),
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, List<Tournament> tournaments) {
    final matches = _getMatchesToDisplay(tournaments);
    if (matches.isEmpty) {
      return const Center(child: Text('No matches found'));
    }
    return PageView.builder(
      scrollDirection: isScreenWide ? Axis.vertical : Axis.horizontal,
      controller: PageController(
        viewportFraction: 0.90,
        initialPage: context.read<LiveStreamMatchIndexCubit>().state,
      ),
      onPageChanged: (index) =>
          context.read<LiveStreamMatchIndexCubit>().setIndex(index),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        return LiveStreamMatch(
          match: matches[index],
          tournament: tournaments[index],
        );
      },
    );
  }
}
