import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/logic/cubit/ranking_players_cubit.dart';
import 'package:tennis_cup/presentation/widgets/ranking_widgets/ranking_player.dart';

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
    return Expanded(
      child: BlocBuilder<RankingPlayersCubit, RankingPlayersState>(
        builder: (context, state) {
          if (state.isLoading && state.players.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!state.isLoading && state.players.isEmpty) {
            return const Center(child: Text('No players found'));
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: state.players.length,
            itemBuilder: (ctx, index) =>
                RankingPlayer(player: state.players[index]),
          );
        },
      ),
    );
  }
}
