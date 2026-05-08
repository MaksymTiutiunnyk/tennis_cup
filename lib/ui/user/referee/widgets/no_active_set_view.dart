import 'package:flutter/material.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/services/dto/match_dto.dart';
import 'package:tennis_cup/ui/user/referee/widgets/no_active_set_player_side.dart';

class NoActiveSetView extends StatelessWidget {
  final Player bluePlayer;
  final Player redPlayer;
  final int blueSetsWon;
  final int redSetsWon;

  /// The most recently finished set (null when no set has been played yet).
  final MatchSetDto? lastSet;
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
    required this.canFinish,
    required this.onFinish,
    this.lastSet,
    this.pendingSetNumber,
    this.onStartSet,
  });

  @override
  Widget build(BuildContext context) {
    if (pendingSetNumber == null) {
      // Match is decided — simple finish view
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
                label: const Text('Finish Match'),
              ),
            ],
          ],
        ),
      );
    }

    // Between sets — 3-column layout showing last set score
    final lastBlueScore = lastSet?.bluePlayerScore;
    final lastRedScore = lastSet?.redPlayerScore;

    return Row(
      children: [
        // Red player
        Expanded(
          child: NoActiveSetPlayerSide(
            player: redPlayer,
            color: const Color(0xFFC62828),
            label: 'Red',
          ),
        ),

        // Center: last set result + start next set
        SizedBox(
          width: 200,
          child: Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Sets: $blueSetsWon – $redSetsWon',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (lastBlueScore != null && lastRedScore != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '$lastBlueScore – $lastRedScore',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Set ${lastSet!.number} score',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onStartSet,
                  icon: const Icon(Icons.play_arrow),
                  label: Text('Start Set $pendingSetNumber'),
                ),
              ],
            ),
          ),
        ),

        // Blue player
        Expanded(
          child: NoActiveSetPlayerSide(
            player: bluePlayer,
            color: const Color(0xFF1565C0),
            label: 'Blue',
          ),
        ),
      ],
    );
  }
}
