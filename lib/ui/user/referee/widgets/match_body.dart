import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/ui/user/referee/view_models/referee_match_cubit.dart';
import 'package:tennis_cup/ui/user/referee/widgets/center_action_panel.dart';
import 'package:tennis_cup/ui/user/referee/widgets/no_active_set_view.dart';
import 'package:tennis_cup/ui/user/referee/widgets/player_column.dart';

class MatchBody extends StatelessWidget {
  final RefereeMatchReady state;
  const MatchBody({super.key, required this.state});

  bool _canFinishSet(int b, int r) {
    final diff = (b - r).abs();
    if (b >= 10 && r >= 10) return diff == 2;
    return (b == 11 || r == 11) && diff <= 11 && diff >= 2;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RefereeMatchCubit>();
    final match = state.match;
    final activeSet =
        match.sets.where((s) => s.status == SetStatus.active).firstOrNull;
    final pendingSet =
        match.sets.where((s) => s.status == SetStatus.pending).firstOrNull;

    final blueSetsWon = match.sets
        .where((s) =>
            (s.status == SetStatus.finished ||
                s.status == SetStatus.technicalDefeat) &&
            s.winnerId == match.bluePlayer.id)
        .length;
    final redSetsWon = match.sets
        .where((s) =>
            (s.status == SetStatus.finished ||
                s.status == SetStatus.technicalDefeat) &&
            s.winnerId == match.redPlayer.id)
        .length;

    // Last completed set (for between-sets view)
    final lastFinishedSet = match.sets
        .where((s) =>
            s.status == SetStatus.finished ||
            s.status == SetStatus.technicalDefeat)
        .lastOrNull;

    if (activeSet == null) {
      // Between-sets side arrangement mirrors the last finished set.
      final lastSetNum = lastFinishedSet?.number ?? 1;
      final betweenSetsLeftIsRed = lastSetNum.isOdd;

      return NoActiveSetView(
        bluePlayer: state.bluePlayer,
        redPlayer: state.redPlayer,
        blueSetsWon: blueSetsWon,
        redSetsWon: redSetsWon,
        lastSet: lastFinishedSet,
        leftIsRed: betweenSetsLeftIsRed,
        pendingSetNumber: pendingSet?.number,
        canFinish: pendingSet == null,
        onStartSet:
            pendingSet != null ? () => cubit.startSet(pendingSet.number) : null,
        onFinish: cubit.finishMatch,
      );
    }

    final setNum = activeSet.number;
    final swapped = state.isDisplaySwapped(
      setNum,
      blueScore: activeSet.blueScore,
      redScore: activeSet.redScore,
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
        leftIsRed ? activeSet.redScore : activeSet.blueScore;
    final rightScore =
        leftIsRed ? activeSet.blueScore : activeSet.redScore;

    final leftCards = leftIsRed ? state.redCards : state.blueCards;
    final rightCards = leftIsRed ? state.blueCards : state.redCards;

    final leftBg =
        leftIsRed ? const Color(0xFFC62828) : const Color(0xFF1565C0);
    final rightBg =
        leftIsRed ? const Color(0xFF1565C0) : const Color(0xFFC62828);

    final b = activeSet.blueScore;
    final r = activeSet.redScore;
    final setFinishable = _canFinishSet(b, r);
    final matchFinishable =
        blueSetsWon >= match.setsToWin || redSetsWon >= match.setsToWin;
    final scoringLocked = setFinishable || matchFinishable;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: PlayerColumn(
            key: ValueKey('player-${leftPlayer.id}'),
            player: leftPlayer,
            score: leftScore,
            isServing: serverId != null && serverId == leftPlayer.id,
            issuedCards: leftCards,
            bgColor: leftBg,
            onScore: scoringLocked
                ? null
                : (leftIsRed ? cubit.addPointRed : cubit.addPointBlue),
            compact: compact,
          ),
        ),

        const VerticalDivider(width: 1),

        SizedBox(
          width: compact ? 140 : 168,
          child: CenterActionPanel(
            state: state,
            activeSet: activeSet,
            blueSetsWon: blueSetsWon,
            redSetsWon: redSetsWon,
            scoringLocked: scoringLocked,
            leftIsRed: leftIsRed,
            canFinishSet: setFinishable,
            canFinishMatch: matchFinishable,
          ),
        ),

        const VerticalDivider(width: 1),

        Expanded(
          child: PlayerColumn(
            key: ValueKey('player-${rightPlayer.id}'),
            player: rightPlayer,
            score: rightScore,
            isServing: serverId != null && serverId == rightPlayer.id,
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
