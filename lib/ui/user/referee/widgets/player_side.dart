import 'package:flutter/material.dart';
import 'package:tennis_cup/data/models/user.dart';
import 'package:tennis_cup/ui/core/widgets/player_avatar.dart';

class PlayerSide extends StatelessWidget {
  final User player;
  final Color color;
  final String label;

  const PlayerSide({
    super.key,
    required this.player,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withValues(alpha: 0.08),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PlayerAvatar(imageUrl: player.imageUrl, radius: 48),
          const SizedBox(height: 12),
          Text(
            player.fullName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
