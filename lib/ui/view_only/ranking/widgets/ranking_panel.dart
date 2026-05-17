import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_cup/data/models/user.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/routing/app_router.dart';
import 'package:tennis_cup/ui/view_only/player_search/widgets/player_search.dart';
import 'package:tennis_cup/ui/view_only/ranking/view_models/gender_filter_cubit.dart';
import 'package:tennis_cup/ui/view_only/ranking/widgets/ranking_filters.dart';

class RankingPanel extends StatelessWidget {
  const RankingPanel({super.key});

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: BlocProvider.of<GenderFilterCubit>(context),
        child: const RankingFilters(),
      ),
    );
  }

  void _showPlayerDetails(BuildContext context, User player) {
    Navigator.of(context).pop();
    context.push(
      AppRoutes.playerDetails(player.id.toString()),
      extra: player,
    );
  }

  void _showSearchField(BuildContext context) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => Scaffold(
        body: PlayerSearch(onSelectPlayer: _showPlayerDetails),
      ),
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
                S.of(context).ratingOfPlayers,
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
