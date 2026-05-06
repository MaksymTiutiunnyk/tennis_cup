import 'package:flutter/material.dart';

class ServerButton extends StatelessWidget {
  final dynamic player;
  final bool isSelected;
  final VoidCallback onTap;

  const ServerButton({
    super.key,
    required this.player,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = '${player.name} ${player.surname}${isSelected ? ' 🏓' : ''}';
    final child = Text(
      label,
      maxLines: 2,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
    );

    if (isSelected) {
      return FilledButton.tonal(
        onPressed: onTap,
        child: child,
      );
    }
    return OutlinedButton(
      onPressed: onTap,
      child: child,
    );
  }
}
