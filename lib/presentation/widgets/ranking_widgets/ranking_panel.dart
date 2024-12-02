import 'package:flutter/material.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/presentation/screens/player_details.dart';
import 'package:tennis_cup/presentation/widgets/ranking_widgets/ranking_filters.dart';
import 'package:tennis_cup/presentation/widgets/player_search.dart';

class RankingPanel extends StatelessWidget {
  const RankingPanel({super.key});

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => const RankingFilters(),
    );
  }

  void _showPlayerDetails(BuildContext context, Player player) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => PlayerDetails(player: player),
    ));
  }

  void _showSearchField(BuildContext context) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => PlayerSearch(onSelectPlayer: _showPlayerDetails),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.people_rounded),
              const SizedBox(width: 8),
              Text(
                'Rating of players',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  _showSearchField(context);
                },
                icon: const Icon(Icons.search),
              ),
              IconButton(
                onPressed: () {
                  _showFilters(context);
                },
                icon: const Icon(Icons.filter_list),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
