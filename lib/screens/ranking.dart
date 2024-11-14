import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/providers/player_provider.dart';
import 'package:tennis_cup/widgets/ranking_widgets/ranking_panel.dart';
import 'package:tennis_cup/widgets/ranking_widgets/ranking_player.dart';

class Ranking extends ConsumerStatefulWidget {
  const Ranking({super.key});

  @override
  ConsumerState createState() => _RankingState();
}

class _RankingState extends ConsumerState<Ranking> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    ref.read(playerNotifierProvider.notifier).fetchPlayers(); // Initial fetch
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.atEdge &&
        _scrollController.position.pixels != 0) {
      ref.read(playerNotifierProvider.notifier).fetchPlayers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(playerNotifierProvider);

    return Scaffold(
      body: Column(
        children: [
          const RankingPanel(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: players.length,
              itemBuilder: (ctx, index) => RankingPlayer(
                player: players[index],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
