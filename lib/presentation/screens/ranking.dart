import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/logic/cubit/ranking_players_cubit.dart';
import 'package:tennis_cup/logic/cubit/sex_filter_cubit.dart';
import 'package:tennis_cup/presentation/widgets/ranking_widgets/ranking_panel.dart';
import 'package:tennis_cup/presentation/widgets/ranking_widgets/ranking_players.dart';

class Ranking extends StatelessWidget {
  const Ranking({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RankingPlayersCubit>(
      create: (context) => RankingPlayersCubit(
        playerRepository: ServiceLocator.playerRepository,
      )..fetchPlayers(sex: context.read<SexFilterCubit>().state),
      child: BlocListener<SexFilterCubit, Sex>(
        listener: (context, sex) =>
            context.read<RankingPlayersCubit>().fetchPlayers(sex: sex),
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
