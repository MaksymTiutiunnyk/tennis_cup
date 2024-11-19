import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/providers/ranking_players_provider.dart';
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
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.atEdge &&
        _scrollController.position.pixels != 0) {
      ref.read(rankingPlayersProvider.notifier).fetchPlayers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(rankingPlayersProvider);
    
    Widget content = const Center(child: CircularProgressIndicator());
    if (!players['isLoading'] && players['players'].length == 0) {
      content = const Center(
        child: Text('No players found'),
      );
    } else {
      content = ListView.builder(
        controller: _scrollController,
        itemCount: players['players'].length,
        itemBuilder: (ctx, index) => RankingPlayer(
          player: players['players'][index],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          const RankingPanel(),
          Expanded(child: content),
        ],
      ),
    );
  }
}
