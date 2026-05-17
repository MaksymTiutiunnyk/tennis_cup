import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/user.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/ui/view_only/player_details/view_models/player_tournaments_cubit.dart';
import 'package:tennis_cup/ui/view_only/player_details/widgets/player_tournament.dart';

class PlayerTournaments extends StatelessWidget {
  final User player;

  const PlayerTournaments({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Flexible(
      fit: FlexFit.loose,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 16, 8, 8),
            child: Row(
              children: [
                const Icon(Icons.emoji_events),
                const SizedBox(width: 8),
                Text(s.tournaments),
              ],
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: BlocBuilder<PlayerTournamentsCubit, PlayerTournamentsState>(
              builder: (context, state) => switch (state) {
                PlayerTournamentsLoading() =>
                  const Center(child: CircularProgressIndicator()),
                PlayerTournamentsError(:final message) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline,
                              color: Theme.of(context).colorScheme.error,
                              size: 40),
                          const SizedBox(height: 8),
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error),
                          ),
                        ],
                      ),
                    ),
                  ),
                PlayerTournamentsLoaded(:final tournaments)
                    when tournaments.isEmpty =>
                  Center(child: Text(s.noTournamentsFound)),
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
