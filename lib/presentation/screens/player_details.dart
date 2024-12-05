import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/logic/cubit/player_tournaments_cubit.dart';
import 'package:tennis_cup/presentation/widgets/player_widgets/player_details_scrollable.dart';

class PlayerDetails extends StatelessWidget {
  final Player player;
  const PlayerDetails({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PlayerTournamentsCubit>(
      create: (context) => PlayerTournamentsCubit(player),
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 35,
          title: const Text("Tennis Cup: Player's statistics"),
        ),
        body: PlayerDetailsScrollable(player),
      ),
    );
  }
}
