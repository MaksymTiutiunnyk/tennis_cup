import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/logic/cubit/players_tournaments_cubit.dart';
import 'package:tennis_cup/presentation/widgets/comparison_widgets.dart/players_comparison_scrollable.dart';

class PlayersComparison extends StatelessWidget {
  final Player player1, player2;
  const PlayersComparison(
      {super.key, required this.player1, required this.player2});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PlayersTournamentsCubit>(
      create: (context) => PlayersTournamentsCubit(player1, player2),
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 35,
          title: const Text('Tennis Cup: Players comparison'),
        ),
        body: PlayersComparisonScrollable(player1: player1, player2: player2),
      ),
    );
  }
}
