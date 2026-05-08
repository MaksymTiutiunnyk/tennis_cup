import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/ui/user/referee/view_models/referee_match_cubit.dart';
import 'package:tennis_cup/ui/user/referee/widgets/center_action_panel.dart';
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

    // Last completed set (for between-sets view)
    final lastFinishedSet = match.sets
        .where((s) => s.status == 'FINISHED' || s.status == 'TECHNICAL_DEFEAT')
        .lastOrNull;

    if (activeSet == null) {
      return NoActiveSetView(
        bluePlayer: state.bluePlayer,
        redPlayer: state.redPlayer,
        blueSetsWon: blueSetsWon,
        redSetsWon: redSetsWon,
        lastSet: lastFinishedSet,
        pendingSetNumber: pendingSet?.number,
        canFinish: pendingSet == null,
        onStartSet: pendingSet != null
            ? () => cubit.startSet(pendingSet.number)
            : null,
        onFinish: cubit.finishMatch,
      );
    }

    final setNum = activeSet.number;
    final swapped = state.isDisplaySwapped(
      setNum,
      blueScore: activeSet.bluePlayerScore,
      redScore: activeSet.redPlayerScore,
    );
    final serverId = state.currentServerId();
    final compact = MediaQuery.sizeOf(context).height < 520 ||
        MediaQuery.sizeOf(context).width < 760;

    // Odd sets (not swapped): left = red, right = blue
    // Even sets (swapped): left = blue, right = red
    final leftPlayer = swapped ? state.bluePlayer : state.redPlayer;
    final rightPlayer = swapped ? state.redPlayer : state.bluePlayer;
    final leftIsRed = !swapped;

    final leftScore =
        leftIsRed ? activeSet.redPlayerScore : activeSet.bluePlayerScore;
    final rightScore =
        leftIsRed ? activeSet.bluePlayerScore : activeSet.redPlayerScore;

    final leftCards = leftIsRed ? state.redCards : state.blueCards;
    final rightCards = leftIsRed ? state.blueCards : state.redCards;

    final leftBg =
        leftIsRed ? const Color(0xFFC62828) : const Color(0xFF1565C0);
    final rightBg =
        leftIsRed ? const Color(0xFF1565C0) : const Color(0xFFC62828);

    // Lock scoring once the set (or match) is ready to be finalised —
    // the score can't legally advance past this point.
    final b = activeSet.bluePlayerScore;
    final r = activeSet.redPlayerScore;
    final setFinishable = (b >= 11 || r >= 11) && (b - r).abs() >= 2;
    final matchFinishable = blueSetsWon >= 3 || redSetsWon >= 3;
    final scoringLocked = setFinishable || matchFinishable;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left player column
        Expanded(
          child: PlayerColumn(
            key: const ValueKey('left-score'),
            player: leftPlayer,
            score: leftScore,
            isServing: serverId != null && serverId == leftPlayer.userId,
            issuedCards: leftCards,
            bgColor: leftBg,
            onScore: scoringLocked
                ? null
                : (leftIsRed ? cubit.addPointRed : cubit.addPointBlue),
            compact: compact,
          ),
        ),

        const VerticalDivider(width: 1),

        // Center action panel
        SizedBox(
          width: compact ? 140 : 168,
          child: CenterActionPanel(
            state: state,
            activeSet: activeSet,
            blueSetsWon: blueSetsWon,
            redSetsWon: redSetsWon,
          ),
        ),

        const VerticalDivider(width: 1),

        // Right player column
        Expanded(
          child: PlayerColumn(
            key: const ValueKey('right-score'),
            player: rightPlayer,
            score: rightScore,
            isServing: serverId != null && serverId == rightPlayer.userId,
            issuedCards: rightCards,
            bgColor: rightBg,
            onScore: scoringLocked
                ? null
                : (leftIsRed ? cubit.addPointBlue : cubit.addPointRed),
            compact: compact,
          ),
        ),
      ],
    );
  }
}
