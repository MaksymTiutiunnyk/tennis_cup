import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/data/models/user.dart';
import 'package:tennis_cup/ui/view_only/player_comparison/view_models/head_to_head_cubit.dart';
import 'package:tennis_cup/ui/view_only/player_comparison/widgets/scrollable_body.dart';

class PlayersComparison extends StatelessWidget {
  final User player1, player2;
  const PlayersComparison(
      {super.key, required this.player1, required this.player2});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HeadToHeadCubit>(
      create: (_) => HeadToHeadCubit(
        player1,
        player2,
        matchRepository: ServiceLocator.matchRepository,
      ),
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 35,
          title: const Text('Tennis Cup: Players comparison'),
        ),
        body: ScrollableBody(player1: player1, player2: player2),
      ),
    );
  }
}
