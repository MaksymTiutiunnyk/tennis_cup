import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/data/models/user.dart';
import 'package:tennis_cup/ui/view_only/player_details/view_models/player_tournaments_cubit.dart';
import 'package:tennis_cup/ui/view_only/player_details/widgets/scrollable_body.dart';

class PlayerDetails extends StatelessWidget {
  final User player;
  const PlayerDetails({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PlayerTournamentsCubit>(
      create: (context) => PlayerTournamentsCubit(
        player,
        tournamentRepository: ServiceLocator.tournamentRepository,
      ),
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 35,
          title: const Text("Tennis Cup: Player's statistics"),
        ),
        body: ScrollableBody(player),
      ),
    );
  }
}
