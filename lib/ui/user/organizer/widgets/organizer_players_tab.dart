import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/ui/user/organizer/widgets/players_view.dart';
import 'package:tennis_cup/ui/view_only/ranking/view_models/ranking_players_cubit.dart';

class OrganizerPlayersTab extends StatelessWidget {
  const OrganizerPlayersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RankingPlayersCubit(
        playerRepository: ServiceLocator.playerRepository,
      )..fetchPlayers(sex: Sex.All, size: 50),
      child: const PlayersView(),
    );
  }
}
