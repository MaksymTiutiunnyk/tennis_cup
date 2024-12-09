import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/logic/cubit/players_tournaments_cubit.dart';
import 'package:tennis_cup/presentation/widgets/comparison_widgets.dart/players_match.dart';

class PlayersMatches extends StatelessWidget {
  final Player player1, player2;
  const PlayersMatches(
      {super.key, required this.player1, required this.player2});

  List<PlayersMatch> _getPlayersMatches(Tournament tournament) {
    final List<PlayersMatch> playersMatches = [];

    for (Match match in tournament.matches!) {
      if ((match.bluePlayer.playerId == player1.playerId ||
              match.redPlayer.playerId == player1.playerId) &&
          (match.bluePlayer.playerId == player2.playerId ||
              match.redPlayer.playerId == player2.playerId)) {
        playersMatches.add(PlayersMatch(
          player1: player1,
          player2: player2,
          match: match,
          tournament: tournament,
        ));
      }
    }

    return playersMatches;
  }

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
          child: BlocBuilder<PlayersTournamentsCubit, PlayersTournamentsState>(
            builder: (context, state) {
              if (state.isLoading && state.tournaments.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.errorMessage != null) {
                return const Center(child: Text('Oops, something went wrong'));
              }

              final playersMatches = [];
              for (Tournament tournament in state.tournaments) {
                playersMatches.addAll(_getPlayersMatches(tournament));
              }
              if (playersMatches.isEmpty) {
                return const Center(child: Text('No matches found'));
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: playersMatches.length,
                itemBuilder: (context, index) => playersMatches[index],
              );
            },
          ),
        ),
      ],
    );
  }
}
