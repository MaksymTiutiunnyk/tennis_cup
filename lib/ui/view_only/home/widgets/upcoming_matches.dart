import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/match_view.dart';
import 'package:tennis_cup/ui/view_only/home/view_models/upcoming_tournaments_cubit.dart';
import 'package:tennis_cup/ui/view_only/home/widgets/upcoming_match.dart';

class UpcomingMatches extends StatelessWidget {
  final bool isScrollable;
  const UpcomingMatches({super.key, this.isScrollable = true});

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
                UpcomingTournamentsLoaded(:final matches) =>
                  _buildList(matches),
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<MatchView> matches) {
    if (matches.isEmpty) {
      return const Center(child: Text('No matches found'));
    }
    return ListView.builder(
      physics: isScrollable ? null : const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: matches.length,
      itemBuilder: (context, index) {
        return UpcomingMatch(match: matches[index]);
      },
    );
  }
}
