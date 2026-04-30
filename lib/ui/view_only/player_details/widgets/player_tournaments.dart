import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/ui/view_only/player_details/view_models/player_tournaments_cubit.dart';
import 'package:tennis_cup/ui/view_only/player_details/widgets/player_tournament.dart';

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
              builder: (context, state) => switch (state) {
                PlayerTournamentsLoading() =>
                  const Center(child: CircularProgressIndicator()),
                PlayerTournamentsError() =>
                  const Center(child: Text('Oops, something went wrong')),
                PlayerTournamentsLoaded(:final tournaments)
                    when tournaments.isEmpty =>
                  const Center(child: Text('No tournaments found')),
                PlayerTournamentsLoaded(:final tournaments) =>
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tournaments.length,
                    itemBuilder: (ctx, index) => PlayerTournament(
                      tournament: tournaments[index],
                      player: player,
                    ),
                  ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
