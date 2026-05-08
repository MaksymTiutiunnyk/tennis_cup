import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/ui/user/referee/view_models/referee_match_cubit.dart';
import 'package:tennis_cup/ui/user/referee/widgets/center_panel.dart';
import 'package:tennis_cup/ui/user/referee/widgets/player_side.dart';

class PendingMatchView extends StatelessWidget {
  final RefereeMatchReady state;
  final VoidCallback onStartMatch;

  const PendingMatchView({
    super.key,
    required this.state,
    required this.onStartMatch,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RefereeMatchCubit>();
    final blue = state.bluePlayer;
    final red = state.redPlayer;

    return Row(
      children: [
        // Red player
        Expanded(
            child: PlayerSide(
                player: red, color: const Color(0xFFC62828), label: 'Red')),

        // Center: server selection + start
        SizedBox(
          width: 200,
          child: CenterPanel(
            state: state,
            blue: blue,
            red: red,
            onSelectServer: cubit.setFirstServer,
            onStartMatch: onStartMatch,
          ),
        ),

        // Blue player
        Expanded(
            child: PlayerSide(
                player: blue, color: const Color(0xFF1565C0), label: 'Blue')),
      ],
    );
  }
}
