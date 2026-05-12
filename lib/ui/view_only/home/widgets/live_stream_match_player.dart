import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/routing/app_router.dart';
import 'package:tennis_cup/ui/core/widgets/player_avatar.dart';

class LiveStreamMatchPlayer extends StatelessWidget {
  final Player player;
  final String label;

  const LiveStreamMatchPlayer(
      {required this.player, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(
        AppRoutes.playerDetails(player.userId.toString()),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              PlayerAvatar(imageUrl: player.imageUrl, radius: 20),
              const SizedBox(width: 8),
              Text(
                player.fullName,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
