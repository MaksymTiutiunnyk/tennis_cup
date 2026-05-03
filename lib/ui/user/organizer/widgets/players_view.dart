import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/models/user_role.dart';
import 'package:tennis_cup/ui/user/core/view_models/active_role_cubit.dart';
import 'package:tennis_cup/ui/user/organizer/widgets/player_row.dart';
import 'package:tennis_cup/ui/view_only/ranking/view_models/ranking_players_cubit.dart';

class PlayersView extends StatelessWidget {
  const PlayersView({super.key});

  @override
  Widget build(BuildContext context) {
    final isAdmin = context
        .watch<ActiveRoleCubit>()
        .state
        .availableRoles
        .contains(UserRole.admin);

    return BlocBuilder<RankingPlayersCubit, RankingPlayersState>(
      builder: (context, state) => switch (state) {
        RankingPlayersLoading() =>
          const Center(child: CircularProgressIndicator()),
        RankingPlayersError() => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Failed to load players'),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context
                      .read<RankingPlayersCubit>()
                      .fetchPlayers(sex: Sex.All, size: 50),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        RankingPlayersLoaded(players: final players) when players.isEmpty =>
          const Center(child: Text('No players found')),
        RankingPlayersLoaded(players: final players) => RefreshIndicator(
            onRefresh: () => context
                .read<RankingPlayersCubit>()
                .fetchPlayers(sex: Sex.All, size: 50),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: players.length,
              itemBuilder: (_, i) =>
                  PlayerRow(player: players[i], isAdmin: isAdmin),
            ),
          ),
        RankingPlayersLoadingMore(players: final players) => ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: players.length + 1,
            itemBuilder: (_, i) => i < players.length
                ? PlayerRow(player: players[i], isAdmin: isAdmin)
                : const Center(child: CircularProgressIndicator()),
          ),
      },
    );
  }
}
