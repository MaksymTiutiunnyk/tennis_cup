import 'package:flutter/material.dart';
import 'package:tennis_cup/data/models/player.dart';

class ServerTile extends StatelessWidget {
  final Player player;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const ServerTile({
    super.key,
    required this.player,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? color.withValues(alpha: 0.1) : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.sports_tennis : Icons.radio_button_unchecked,
              color: isSelected ? color : null,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                player.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : null,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
