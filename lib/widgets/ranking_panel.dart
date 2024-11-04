import 'package:flutter/material.dart';
import 'package:tennis_cup/widgets/ranking_filters.dart';

class RankingPanel extends StatelessWidget {
  const RankingPanel({super.key});

  void showFilters(BuildContext context) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => const RankingFilters(),
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
                'Ranking of Tennis Cup players',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search),
              ),
              IconButton(
                onPressed: () {
                  showFilters(context);
                },
                icon: const Icon(Icons.filter_list),
              ),
            ],
          )
        ],
      ),
    );
  }
}
