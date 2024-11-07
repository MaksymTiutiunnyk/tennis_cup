import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/model/player.dart';
import 'package:tennis_cup/providers/sex_filter_provider.dart';
import 'package:tennis_cup/widgets/ranking_widgets/ranking_panel.dart';
import 'package:tennis_cup/widgets/ranking_widgets/ranking_player.dart';

class Ranking extends ConsumerWidget {
  const Ranking({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Player> filteredPlayers = ref.watch(filteredPlayersProvider);

    return Scaffold(
      body: Column(
        children: [
          const RankingPanel(),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPlayers.length,
              itemBuilder: (ctx, index) => RankingPlayer(
                player: filteredPlayers[index],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
