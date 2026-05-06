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
  final bool compact;

  const PlayerColumn({
    super.key,
    required this.player,
    required this.score,
    required this.isServing,
    required this.issuedCards,
    required this.bgColor,
    required this.onScore,
    required this.onToggleCard,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final trayCards = MatchCard.values.where((c) => !issuedCards.contains(c));
    final issued = MatchCard.values.where((c) => issuedCards.contains(c));

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: compact ? 4 : 6,
            horizontal: 4,
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: trayCards
                .map(
                  (c) => GestureDetector(
                    onTap: () => onToggleCard(c),
                    child: CardChip(card: c, issued: false),
                  ),
                )
                .toList(),
          ),
        ),
        if (issued.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              runSpacing: 4,
              children: issued
                  .map(
                    (c) => GestureDetector(
                      onTap: () => onToggleCard(c),
                      child: CardChip(card: c, issued: true),
                    ),
                  )
                  .toList(),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  '${player.name} ${player.surname}',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: compact
                      ? Theme.of(context).textTheme.bodySmall
                      : Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              if (isServing) ...[
                const SizedBox(width: 4),
                const Text('🏓', style: TextStyle(fontSize: 14)),
              ],
            ],
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: onScore,
            child: Container(
              color: bgColor,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$score',
                  style: TextStyle(
                    fontSize: compact ? 56 : 72,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
