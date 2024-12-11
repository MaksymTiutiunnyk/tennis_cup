import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/logic/cubit/player_tournaments_cubit.dart';
import 'package:tennis_cup/presentation/widgets/player_widgets/player_tournament.dart';

class PlayerTournaments extends StatelessWidget {
  final Player player;

  const PlayerTournaments({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.loose,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(8.0, 16, 8, 8),
            child: Row(
              children: [
                Icon(Icons.emoji_events),
                SizedBox(width: 8),
                Text('Tournaments'),
              ],
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: BlocBuilder<PlayerTournamentsCubit, PlayerTournamentsState>(
              builder: (context, state) {
                if (state.isLoading && state.tournaments.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.errorMessage != null) {
                  return const Center(
                    child: Text('Oops, something went wrong'),
                  );
                }

                if (state.tournaments.isEmpty) {
                  return const Center(child: Text('No tournaments found'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.tournaments.length,
                  itemBuilder: (ctx, index) => PlayerTournament(
                    tournament: state.tournaments[index],
                    player: player,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
