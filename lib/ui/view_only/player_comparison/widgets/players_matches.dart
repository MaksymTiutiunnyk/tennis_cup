import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/ui/view_only/player_comparison/view_models/head_to_head_cubit.dart';
import 'package:tennis_cup/ui/view_only/player_comparison/widgets/players_match.dart';

class PlayersMatches extends StatelessWidget {
  final Player player1, player2;
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
                  "Players' matches: ${player1.fullName} vs ${player2.fullName}",
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
                const Center(child: Text('Oops, something went wrong')),
              HeadToHeadLoaded(:final matches) => matches.isEmpty
                  ? const Center(child: Text('No matches found'))
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
