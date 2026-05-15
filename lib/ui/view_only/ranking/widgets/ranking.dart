import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/data/models/gender.dart';
import 'package:tennis_cup/ui/view_only/ranking/view_models/gender_filter_cubit.dart';
import 'package:tennis_cup/ui/view_only/ranking/view_models/ranking_players_cubit.dart';
import 'package:tennis_cup/ui/view_only/ranking/widgets/ranking_panel.dart';
import 'package:tennis_cup/ui/view_only/ranking/widgets/ranking_players.dart';

class Ranking extends StatelessWidget {
  const Ranking({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RankingPlayersCubit>(
      create: (context) => RankingPlayersCubit(
        playerRepository: ServiceLocator.playerRepository,
      )..fetchPlayers(gender: context.read<GenderFilterCubit>().state),
      child: BlocListener<GenderFilterCubit, Gender?>(
        listener: (context, gender) =>
            context.read<RankingPlayersCubit>().fetchPlayers(gender: gender),
        child: const Column(
          children: [
            RankingPanel(),
            RankingPlayers(),
          ],
        ),
      ),
    );
  }
}
