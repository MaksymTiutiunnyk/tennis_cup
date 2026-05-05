import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/ui/user/referee/view_models/referee_match_cubit.dart';
import 'package:tennis_cup/ui/user/referee/widgets/player_side_card.dart';
import 'package:tennis_cup/ui/user/referee/widgets/server_button.dart';

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
    final swapped = !state.initialBlueOnLeft;
    final leftPlayer = swapped ? red : blue;
    final rightPlayer = swapped ? blue : red;
    final blueId = int.tryParse(blue.playerId) ?? -1;
    final redId = int.tryParse(red.playerId) ?? -1;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Next Match',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Players row with swap button
          Row(
            children: [
              Expanded(
                child: PlayerSideCard(
                  player: leftPlayer,
                  label: swapped ? 'Red side' : 'Blue side',
                  color: swapped
                      ? const Color(0xFFC62828)
                      : const Color(0xFF1565C0),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.swap_horiz),
                tooltip: 'Swap sides',
                onPressed: cubit.toggleInitialSide,
              ),
              Expanded(
                child: PlayerSideCard(
                  player: rightPlayer,
                  label: swapped ? 'Blue side' : 'Red side',
                  color: swapped
                      ? const Color(0xFF1565C0)
                      : const Color(0xFFC62828),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'First server',
            style: Theme.of(context).textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ServerButton(
                  player: blue,
                  isSelected: state.firstServerPlayerId == blueId,
                  onTap: () => cubit.setFirstServer(blueId),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ServerButton(
                  player: red,
                  isSelected: state.firstServerPlayerId == redId,
                  onTap: () => cubit.setFirstServer(redId),
                ),
              ),
            ],
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: onStartMatch,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Match'),
          ),
        ],
      ),
    );
  }
}
