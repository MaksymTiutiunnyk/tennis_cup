import 'package:flutter/material.dart';
import 'package:tennis_cup/generated/l10n.dart';

String cardLabel(String cardType, S s) => switch (cardType) {
      'WHITE' => s.whiteCard,
      'YELLOW' => s.yellowCard,
      'RED' => s.redCard,
      _ => cardType,
    };

class CardChip extends StatelessWidget {
  final String cardType; // 'WHITE', 'YELLOW', 'RED'
  final bool enabled;

  const CardChip({
    super.key,
    required this.cardType,
    this.enabled = true,
  });

  Color get _color => switch (cardType) {
        'YELLOW' => Colors.yellow.shade600,
        'RED' => Colors.red.shade700,
        _ => Colors.grey.shade200, // WHITE
      };

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.35,
      child: Container(
        width: 22,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: _color,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: Colors.black54, width: 1.5),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2)],
        ),
      ),
    );
  }
}
