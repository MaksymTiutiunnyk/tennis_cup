import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/services/dto/match_dto.dart';
import 'package:tennis_cup/ui/user/referee/view_models/referee_match_cubit.dart';
import 'package:tennis_cup/ui/user/referee/widgets/card_chip.dart';

class PlayerColumn extends StatelessWidget {
  final Player player;
  final int score;
  final bool isServing;
  final List<MatchCardDto> issuedCards;
  final Color bgColor;
  final VoidCallback? onScore;
  final bool compact;

  const PlayerColumn({
    super.key,
    required this.player,
    required this.score,
    required this.isServing,
    required this.issuedCards,
    required this.bgColor,
    required this.onScore,
    this.compact = false,
  });

  Future<void> _confirmRevoke(BuildContext context, MatchCardDto card) async {
    final cubit = context.read<RefereeMatchCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revoke Card'),
        content: Text(
            'Revoke the ${card.cardType.toLowerCase()} card issued to ${player.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      cubit.revokeCard(card.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Player name + serve indicator
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: compact ? 4 : 6,
            horizontal: 4,
          ),
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

        // Score tap area
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

        // Issued cards — tappable to revoke
        if (issuedCards.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              runSpacing: 4,
              children: issuedCards
                  .map(
                    (card) => GestureDetector(
                      onTap: () => _confirmRevoke(context, card),
                      child: CardChip(cardType: card.cardType),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}
