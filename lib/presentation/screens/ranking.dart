import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/logic/cubit/ranking_players_cubit.dart';
import 'package:tennis_cup/logic/cubit/sex_filter_cubit.dart';
import 'package:tennis_cup/presentation/widgets/ranking_widgets/ranking_panel.dart';
import 'package:tennis_cup/presentation/widgets/ranking_widgets/ranking_players.dart';

class Ranking extends StatelessWidget {
  const Ranking({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SexFilterCubit>(
          create: (context) => SexFilterCubit(),
        ),
        BlocProvider<RankingPlayersCubit>(
          create: (context) => RankingPlayersCubit(
            sexFilterCubit: BlocProvider.of<SexFilterCubit>(context),
          )..fetchPlayersInitially(),
        ),
      ],
      child: const Scaffold(
        body: Column(
          children: [
            RankingPanel(),
            RankingPlayers(),
          ],
        ),
      ),
    );
  }
}
