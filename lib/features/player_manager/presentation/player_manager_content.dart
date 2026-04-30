import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/features/player_manager/logic/invitations_cubit.dart';
import 'package:tennis_cup/features/player_manager/presentation/settings_tab.dart';
import 'package:tennis_cup/features/player_manager/presentation/tournaments_tab.dart';

class PlayerManagerContent extends StatelessWidget {
  final int tabIndex;

  const PlayerManagerContent({super.key, required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    return switch (tabIndex) {
      1 => const Center(child: Text('Notifications')),
      2 => const SettingsTab(),
      _ => BlocProvider(
          create: (_) => InvitationsCubit(
            repository: ServiceLocator.invitationsRepository,
            // TODO: replace with the authenticated player's id once the auth
            // cubit exposes it.
            playerId: '1',
          ),
          child: const TournamentsTab(),
        ),
    };
  }
}
