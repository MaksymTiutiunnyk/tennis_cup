import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/ui/view_only/ranking/view_models/ranking_players_cubit.dart';
import 'package:tennis_cup/ui/view_only/ranking/widgets/ranking_player.dart';

class RankingPlayers extends StatefulWidget {
  const RankingPlayers({super.key});

  @override
  State<RankingPlayers> createState() {
    return _RankingPlayersState();
  }
}

class _RankingPlayersState extends State<RankingPlayers> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.atEdge &&
        _scrollController.position.pixels != 0) {
      context.read<RankingPlayersCubit>().fetchPlayersWhenScrolled();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Expanded(
      child: BlocBuilder<RankingPlayersCubit, RankingPlayersState>(
        builder: (context, state) => switch (state) {
          RankingPlayersLoading() =>
            const Center(child: CircularProgressIndicator()),
          RankingPlayersError(:final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        color: Theme.of(context).colorScheme.error, size: 40),
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
          RankingPlayersLoaded(:final players) when players.isEmpty =>
            Center(child: Text(s.noPlayersFound)),
          RankingPlayersLoaded(:final players) =>
            ListView.builder(
              controller: _scrollController,
              itemCount: players.length,
              itemBuilder: (ctx, index) =>
                  RankingPlayer(player: players[index]),
            ),
          RankingPlayersLoadingMore(:final players) =>
            ListView.builder(
              controller: _scrollController,
              itemCount: players.length + 1,
              itemBuilder: (ctx, index) {
                if (index == players.length) {
                  return const Padding(
                    padding: EdgeInsets.all(8),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return RankingPlayer(player: players[index]);
              },
            ),
        },
      ),
    );
  }
}
