import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/user.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/ui/view_only/player_comparison/view_models/head_to_head_cubit.dart';
import 'package:tennis_cup/ui/view_only/player_comparison/widgets/players_match.dart';

class PlayersMatches extends StatelessWidget {
  final User player1, player2;
  const PlayersMatches(
      {super.key, required this.player1, required this.player2});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Row(
            children: [
              const Icon(Icons.people),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  S.of(context).playersMatchesTitle(player1.fullName, player2.fullName),
                  softWrap: true,
                ),
              ),
            ],
          ),
        ),
        Flexible(
          fit: FlexFit.loose,
          child: BlocBuilder<HeadToHeadCubit, HeadToHeadState>(
            builder: (context, state) => switch (state) {
              HeadToHeadLoading() =>
                const Center(child: CircularProgressIndicator()),
              HeadToHeadError() =>
                Center(child: Text(S.of(context).oopsSomethingWentWrong)),
              HeadToHeadLoaded(:final matches) => matches.isEmpty
                  ? Center(child: Text(S.of(context).noMatchesFound))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: matches.length,
                      itemBuilder: (context, index) => PlayersMatch(
                        player1: player1,
                        player2: player2,
                        match: matches[index],
                      ),
                    ),
            },
          ),
        ),
      ],
    );
  }
}
