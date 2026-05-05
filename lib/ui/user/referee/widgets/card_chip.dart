import 'package:flutter/material.dart';
import 'package:tennis_cup/ui/user/referee/view_models/referee_match_cubit.dart';

class CardChip extends StatelessWidget {
  final MatchCard card;
  final bool issued;

  const CardChip({super.key, required this.card, required this.issued});

  @override
  Widget build(BuildContext context) {
    final color = switch (card) {
      MatchCard.yellow => Colors.yellow.shade600,
      MatchCard.red1 || MatchCard.red2 => Colors.red.shade700,
      MatchCard.whiteTimeout => Colors.white,
    };
    return Container(
      width: 22,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: issued ? Colors.black87 : Colors.black26,
          width: issued ? 2 : 1,
        ),
        boxShadow: issued
            ? [const BoxShadow(color: Colors.black38, blurRadius: 3)]
            : null,
      ),
    );
  }
}
