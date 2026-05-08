import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/ui/user/referee/view_models/referee_match_cubit.dart';
import 'package:tennis_cup/ui/user/referee/widgets/action_bar.dart';
import 'package:tennis_cup/ui/user/referee/widgets/no_active_set_view.dart';
import 'package:tennis_cup/ui/user/referee/widgets/player_column.dart';

class MatchBody extends StatelessWidget {
  final RefereeMatchReady state;
  const MatchBody({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RefereeMatchCubit>();
    final match = state.match;
    final activeSet = match.sets.where((s) => s.status == 'ACTIVE').firstOrNull;
    final pendingSet =
        match.sets.where((s) => s.status == 'PENDING').firstOrNull;

    final blueSetsWon = match.sets
        .where((s) =>
            (s.status == 'FINISHED' || s.status == 'TECHNICAL_DEFEAT') &&
            s.winnerId == match.bluePlayerId)
        .length;
    final redSetsWon = match.sets
        .where((s) =>
            (s.status == 'FINISHED' || s.status == 'TECHNICAL_DEFEAT') &&
            s.winnerId == match.redPlayerId)
        .length;

    if (activeSet == null && pendingSet == null) {
      return NoActiveSetView(
        blueSetsWon: blueSetsWon,
        redSetsWon: redSetsWon,
        canFinish: true,
        onFinish: cubit.finishMatch,
      );
    }

    if (activeSet == null && pendingSet != null) {
      return NoActiveSetView(
        blueSetsWon: blueSetsWon,
        redSetsWon: redSetsWon,
        pendingSetNumber: pendingSet.number,
        canFinish: false,
        onStartSet: () => cubit.startSet(pendingSet.number),
        onFinish: cubit.finishMatch,
      );
    }

    final setNum = activeSet!.number;
    final swapped = state.isDisplaySwapped(setNum);
    final serverId = state.currentServerId();
    final compact = MediaQuery.sizeOf(context).height < 520 ||
        MediaQuery.sizeOf(context).width < 760;

    final leftPlayer = swapped ? state.redPlayer : state.bluePlayer;
    final rightPlayer = swapped ? state.bluePlayer : state.redPlayer;
    final leftIsBlue = !swapped;

    final leftScore =
        leftIsBlue ? activeSet.bluePlayerScore : activeSet.redPlayerScore;
    final rightScore =
        leftIsBlue ? activeSet.redPlayerScore : activeSet.bluePlayerScore;

    final leftIssuedCards =
        leftIsBlue ? state.blueIssuedCards : state.redIssuedCards;
    final rightIssuedCards =
        leftIsBlue ? state.redIssuedCards : state.blueIssuedCards;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: compact ? 4 : 8),
          child: Text(
            'Set $setNum  ·  $blueSetsWon – $redSetsWon',
            style: compact
                ? Theme.of(context).textTheme.titleSmall
                : Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: PlayerColumn(
                  key: const ValueKey('left-score'),
                  player: leftPlayer,
                  score: leftScore,
                  isServing: serverId != null && serverId == leftPlayer.userId,
                  issuedCards: leftIssuedCards,
                  bgColor: leftIsBlue
                      ? const Color(0xFF1565C0)
                      : const Color(0xFFC62828),
                  onScore: leftIsBlue ? cubit.addPointBlue : cubit.addPointRed,
                  onToggleCard: (card) => cubit.toggleCard(leftIsBlue, card),
                  compact: compact,
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: PlayerColumn(
                  key: const ValueKey('right-score'),
                  player: rightPlayer,
                  score: rightScore,
                  isServing: serverId != null && serverId == rightPlayer.userId,
                  issuedCards: rightIssuedCards,
                  bgColor: leftIsBlue
                      ? const Color(0xFFC62828)
                      : const Color(0xFF1565C0),
                  onScore: leftIsBlue ? cubit.addPointRed : cubit.addPointBlue,
                  onToggleCard: (card) => cubit.toggleCard(!leftIsBlue, card),
                  compact: compact,
                ),
              ),
            ],
          ),
        ),
        ActionBar(
          state: state,
          activeSet: activeSet,
          blueSetsWon: blueSetsWon,
          redSetsWon: redSetsWon,
          compact: compact,
        ),
      ],
    );
  }
}
