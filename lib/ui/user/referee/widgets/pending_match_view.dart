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

  Widget _buildPlayersLayout({
    required BuildContext context,
    required bool stacked,
    required dynamic leftPlayer,
    required dynamic rightPlayer,
    required bool swapped,
    required VoidCallback onSwap,
  }) {
    final leftCard = PlayerSideCard(
      player: leftPlayer,
      label: swapped ? 'Red side' : 'Blue side',
      color: swapped ? const Color(0xFFC62828) : const Color(0xFF1565C0),
    );
    final rightCard = PlayerSideCard(
      player: rightPlayer,
      label: swapped ? 'Blue side' : 'Red side',
      color: swapped ? const Color(0xFF1565C0) : const Color(0xFFC62828),
    );

    if (stacked) {
      return Column(
        children: [
          leftCard,
          IconButton(
            icon: const Icon(Icons.swap_vert),
            tooltip: 'Swap sides',
            onPressed: onSwap,
          ),
          rightCard,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: leftCard),
        IconButton(
          icon: const Icon(Icons.swap_horiz),
          tooltip: 'Swap sides',
          onPressed: onSwap,
        ),
        Expanded(child: rightCard),
      ],
    );
  }

  Widget _buildServerLayout({
    required bool stacked,
    required Widget blueButton,
    required Widget redButton,
  }) {
    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          blueButton,
          const SizedBox(height: 8),
          redButton,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: blueButton),
        const SizedBox(width: 8),
        Expanded(child: redButton),
      ],
    );
  }

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

    return LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 700;
          final scrollable = constraints.maxHeight < 430;
          final content = Padding(
            padding: EdgeInsets.all(scrollable ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Next Match',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                _buildPlayersLayout(
                  context: context,
                  stacked: stacked,
                  leftPlayer: leftPlayer,
                  rightPlayer: rightPlayer,
                  swapped: swapped,
                  onSwap: cubit.toggleInitialSide,
                ),
                const SizedBox(height: 24),
                Text(
                  'First server',
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                _buildServerLayout(
                  stacked: stacked,
                  blueButton: ServerButton(
                    player: blue,
                    isSelected: state.firstServerPlayerId == blueId,
                    onTap: () => cubit.setFirstServer(blueId),
                  ),
                  redButton: ServerButton(
                    player: red,
                    isSelected: state.firstServerPlayerId == redId,
                    onTap: () => cubit.setFirstServer(redId),
                  ),
                ),
                SizedBox(height: scrollable ? 24 : 32),
                FilledButton.icon(
                  onPressed: onStartMatch,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Match'),
                ),
              ],
            ),
          );

          if (scrollable) {
            return SingleChildScrollView(child: content);
          }

          return content;
        },
      );
  }
}
