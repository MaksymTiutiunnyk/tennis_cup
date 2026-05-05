import 'package:flutter/material.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/ui/user/referee/view_models/referee_match_cubit.dart';
import 'package:tennis_cup/ui/user/referee/widgets/card_chip.dart';

class PlayerColumn extends StatelessWidget {
  final Player player;
  final int score;
  final bool isServing;
  final CardState issuedCards;
  final Color bgColor;
  final VoidCallback onScore;
  final void Function(MatchCard) onToggleCard;

  const PlayerColumn({
    super.key,
    required this.player,
    required this.score,
    required this.isServing,
    required this.issuedCards,
    required this.bgColor,
    required this.onScore,
    required this.onToggleCard,
  });

  @override
  Widget build(BuildContext context) {
    final trayCards = MatchCard.values.where((c) => !issuedCards.contains(c));
    final issued = MatchCard.values.where((c) => issuedCards.contains(c));

    return Column(
      children: [
        // Card tray (above player)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: trayCards
                .map((c) => GestureDetector(
                      onTap: () => onToggleCard(c),
                      child: CardChip(card: c, issued: false),
                    ))
                .toList(),
          ),
        ),
        // Issued cards (below card tray)
        if (issued.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: issued
                  .map((c) => GestureDetector(
                        onTap: () => onToggleCard(c),
                        child: CardChip(card: c, issued: true),
                      ))
                  .toList(),
            ),
          ),
        // Player name + server indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  '${player.name} ${player.surname}',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              if (isServing) ...[
                const SizedBox(width: 4),
                const Text('🏓', style: TextStyle(fontSize: 14)),
              ],
            ],
          ),
        ),
        // Score tap area
        Expanded(
          child: InkWell(
            onTap: onScore,
            child: Container(
              color: bgColor,
              alignment: Alignment.center,
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
