import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/ui/view_only/home/view_models/upcoming_tournaments_cubit.dart';
import 'package:tennis_cup/ui/view_only/home/widgets/upcoming_match.dart';

class UpcomingMatches extends StatelessWidget {
  final bool isScrollable;
  const UpcomingMatches({super.key, this.isScrollable = true});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
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
                  s.upcomingMatchesTitle,
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
                  Center(child: Text(S.of(context).oopsSomethingWentWrong)),
                UpcomingTournamentsLoaded(:final matches) =>
                  _buildList(context, matches),
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Match> matches) {
    if (matches.isEmpty) {
      return Center(child: Text(S.of(context).noMatchesFound));
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
