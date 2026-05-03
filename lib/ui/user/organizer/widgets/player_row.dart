import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/routing/app_router.dart';
import 'package:tennis_cup/ui/core/widgets/player_avatar.dart';

class PlayerRow extends StatelessWidget {
  final Player player;
  final bool isAdmin;

  const PlayerRow({super.key, required this.player, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: PlayerAvatar(imageUrl: player.imageUrl, radius: 20),
      title: Text(player.fullName),
      subtitle: Text(player.sex == Sex.Men ? 'Male' : 'Female'),
      trailing: isAdmin
          ? IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Player profile editing is not yet available (endpoint pending)'),
                ),
              ),
            )
          : null,
      onTap: () =>
          context.push(AppRoutes.playerDetails(player.playerId), extra: player),
    );
  }
}
