import 'package:flutter/material.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/models/user.dart';
import 'package:tennis_cup/generated/l10n.dart';

class NoActiveSetView extends StatelessWidget {
  final User bluePlayer;
  final User redPlayer;
  final int blueSetsWon;
  final int redSetsWon;
  final MatchSet? lastSet;
  /// Which player is on the left — mirrors the side layout of the last finished set.
  final bool leftIsRed;
  final int? pendingSetNumber;
  final bool canFinish;
  final VoidCallback? onStartSet;
  final VoidCallback onFinish;

  const NoActiveSetView({
    super.key,
    required this.bluePlayer,
    required this.redPlayer,
    required this.blueSetsWon,
    required this.redSetsWon,
    required this.leftIsRed,
    required this.canFinish,
    required this.onFinish,
    this.lastSet,
    this.pendingSetNumber,
    this.onStartSet,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    if (pendingSetNumber == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sets: $blueSetsWon – $redSetsWon',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (canFinish) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onFinish,
                icon: const Icon(Icons.emoji_events),
                label: Text(s.finishMatch),
              ),
            ],
          ],
        ),
      );
    }

    final leftPlayer = leftIsRed ? redPlayer : bluePlayer;
    final rightPlayer = leftIsRed ? bluePlayer : redPlayer;
    final leftBg = leftIsRed ? const Color(0xFFC62828) : const Color(0xFF1565C0);
    final rightBg = leftIsRed ? const Color(0xFF1565C0) : const Color(0xFFC62828);

    final leftScore = lastSet == null
        ? 0
        : (leftIsRed ? lastSet!.redScore : lastSet!.blueScore);
    final rightScore = lastSet == null
        ? 0
        : (leftIsRed ? lastSet!.blueScore : lastSet!.redScore);

    final lastWinnerId = lastSet?.winnerId;
    final displayBlueSets =
        blueSetsWon - (lastWinnerId == bluePlayer.id ? 1 : 0);
    final displayRedSets =
        redSetsWon - (lastWinnerId == redPlayer.id ? 1 : 0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _ScorePanel(
            player: leftPlayer,
            score: leftScore,
            bgColor: leftBg,
          ),
        ),

        const VerticalDivider(width: 1),

        SizedBox(
          width: 168,
          child: Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (lastSet != null) ...[
                  Text(
                    s.setFinished(lastSet!.number),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  '${leftIsRed ? displayRedSets : displayBlueSets} – ${leftIsRed ? displayBlueSets : displayRedSets}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onStartSet,
                  icon: const Icon(Icons.play_arrow),
                  label: Text(s.startSet(pendingSetNumber!)),
                ),
              ],
            ),
          ),
        ),

        const VerticalDivider(width: 1),

        Expanded(
          child: _ScorePanel(
            player: rightPlayer,
            score: rightScore,
            bgColor: rightBg,
          ),
        ),
      ],
    );
  }
}

class _ScorePanel extends StatelessWidget {
  final User player;
  final int score;
  final Color bgColor;

  const _ScorePanel({
    required this.player,
    required this.score,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Text(
            '${player.firstName} ${player.lastName}',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: Container(
            color: bgColor,
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$score',
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
