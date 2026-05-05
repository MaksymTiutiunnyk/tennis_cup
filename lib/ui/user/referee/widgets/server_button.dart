import 'package:flutter/material.dart';

class ServerButton extends StatelessWidget {
  final dynamic player;
  final bool isSelected;
  final VoidCallback onTap;

  const ServerButton(
      {super.key,
      required this.player,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return FilledButton.tonal(
        onPressed: onTap,
        child: Text('${player.name} ${player.surname} 🏓'),
      );
    }
    return OutlinedButton(
      onPressed: onTap,
      child: Text('${player.name} ${player.surname}'),
    );
  }
}
